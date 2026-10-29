*** Settings ***
Documentation    TC__SBTS_SBTS_SBTS_SBTS__STATE__Site_Reset_from_WEBEM
Variables    tc_variables/sbts_sbts_sbts_sbts__state__site_reset_from_webem_alarms_definitions.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${REPEAT_COUNTER}      3    # Number of BTS Reset operations, default value 3
${BTS_LIST}            ALL  # BTS list on which reset operation will be performed. Possible values (by default ALL):
                            # - ALL: action will be performed on all BTS (reset each BTS until last BTS from TL)
                            # - list of selected BTS separated by comma labelized as BTSx (x is test_pc number in init.py) (ex. BTS1, BTS3)
${KPI_LIST}          kpi1a  # Reset Site KPI label list separated by comma. Possible values (by default kpi1a):
                            # - kpi1a: Time spent between first cell down to last cell up
                            # - kpi1b: Time spent between last cell down to first cell up
                            # - kpi1c: Time spent between reset request to first cell up
${BTS1_RESET_WRN_THR_LIST}  600  # BTS1 KPI value list separated by comma. They should be correlated with Reset Site KPI label list.
                                 # By default 600 (secs) for kpi1a
${BTS2_RESET_WRN_THR_LIST}  600  # BTS2 KPI value list separated by comma. They should be correlated with Reset Site KPI label list.
                                 # By default 600 (secs) for kpi1a
${BTS3_RESET_WRN_THR_LIST}  600  # BTS3 KPI value list separated by comma. They should be correlated with Reset Site KPI label list.
                                 # By default 600 (secs) for kpi1a
${BTS4_RESET_WRN_THR_LIST}  600  # BTS4 KPI value list separated by comma. They should be correlated with Reset Site KPI label list.
                                 # By default 600 (secs) for kpi1a
${BTS_MAX_WAIT_TIME}   900  # Maximum time to wait for BTS OnAir after reset (by default 900)
${CB007447_SHARED_RM_SN_EXCEPTIONS_LIST}  # CPRI shared RM serial number list separated by comma that don't support feature CB007447 (only in case
                                          # CB007447 is activated)
${SWCONFIG_CHANGE_FLAG}  False  # Enable/disable HWF flags in swconfig.txt file. By default HWF flags change is disabled: False
${SWCONFIG_FLAG_ACTION}  add  # Action that should be done with the list of HWF flags in swconfig.txt. Possible values: add/remove
                              # - add: check requested HWF flags from swconfig.txt file and set if needed on 0 -> HWF will not be took into use
                              # - remove: check requested HWF flags from swconfig.txt file and remove if set on 0 -> HWF will be took into use
${SWCONFIG_FLAG_LIST}  0x4F0214  # List of HWF flags that will be added/removed in swconfig.txt. User provides the flags with spaces between them.
                                 # Possible values:
                                 # - 0x190030 (OAM_DBG_EnableHwfLoading) till SBTS00_ENB_9999_211214_000014 or on maintenance branches till SBTS22R1
                                 # - 0x4F0214 (ERadLteHas_BB_PERIPHERIES_EnableHwfLoading) from SBTS00_ENB_9999_211214_000014
                                 # For current SW trunk, flag 0x4F0214 should be used
${GRACEFUL_CELL_SHUTDOWN}  True  # Graceful cell shutdown: True or False; default value: True
${BTS_PRIMARY_LINK_LIST}             # BTS primary link set before BTS power off/on operation. Possible values (by default empty):
                                     # - empty (no set required) -> BTS power off/on operations on BTS from ${BTS_LIST} will be performed with
                                     # existing BTS primary link settings
                                     # - single BTS value labeled as BTSx (x is test_pc number in init.py) -> BTS power off/on operations on each
                                     # BTS from ${BTS_LIST} will be performed with BTSx value set as primary link (ex. BTS2 means that BTS2 set
                                     # is required before BTS power off/on on each BTS from ${BTS_LIST})
                                     # - list of BTS values separated by comma labeled as BTSx (x is test_pc number in init.py) -> BTS power off/on
                                     # operations on each BTS from ${BTS_LIST} will be performed with specific BTSx value set as primary link; in
                                     # this case, number of BTS values for primary link settings should be equal with number of BTS on which
                                     # BTS power off/on operations will be performed (ex. BTS2, BTS1 means: BTS2 set required before first BTS
                                     # operations, BTS1 set required before second BTS operations)
${SET_PRIMARY_LINK_TIME}       720   # Time in seconds to wait for Primary Link set on ${BTS_PRIMARY_LINK}, default value: 720 (seconds)
${SET_PRIMARY_LINK_PROCEDURE}  LANE  # Procedure for setting Primary Link set on ${BTS_PRIMARY_LINK}
                                     # Possible values (by default LANE):
                                     # - LANE: by lock/unlock SFP LANE (operations should be enabled on BTS for shared RMOD)
                                     # - BTS: BTS Reset, then BTS power off/on (if BTS reset is unsuccessful)
${ASOx_counters_flag}    False   # Flag for checking dedicated ASOx counters M40014C10 and M40014C11; Possible values: True, False;
                                 # Default value: False
${PM_Counters_Check}    False    # PM counters check Flag for checking M40015C10 (short link break)
                                 # Possible values: True or False; by default: False
${cpriSyncBreakTime}    500          # If PM_Counter_Check = True then pls set cpriSyncBreakTime duration in ms;
                                     # possible values: 100...10000, step 100ms; ex:500
${stickToSyncSourcePeriod}    400    # If PM_Counter_Check = True then pls set stickToSyncSourcePeriod duration in ms;
                                     # possible values: 0...10000, step 10ms; ex: 400
${DELAY_BETWEEN_SNAPSHOTS}   30      # In case of Snapshot collections during test (PM_Counters_Check=True and PM Counter Check fail),
                                     # defined as the delay time between Snapshot collections measured in seconds. Default value: 30

*** Keywords ***
TC__SBTS_SBTS_SBTS_SBTS__STATE__Site_Reset_from_WEBEM
     [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-25420
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  SBTS-SBTS-SBTS test case for BTS reset, - x times sequence.
    ...  x - value of REPEAT_COUNTER parameter (default: 3)
    ...  The main steps performed for the test are:
    ...  - check initial state and alarms for all BTS
    ...  - get all BTS info
    ...  - perform BTS reset operations checking alarms and state
    ...  - check final state and alarms for for all BTS
    ...  Pass criteria: BTS reset operation works as expected; states and alarms are as expected
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 28.06.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25420 - [5G][CB008693][CNI-58093] New TC
    ...  SBTS_SBTS_SBTS_SBTS__Site_Reset_from_WEBEM - DSS adaptation
    ...  - 25.07.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25716 - [5G][CB008693][CNI-58093]SBTS_SBTS_SBTS_SBTS__Site_Reset_from_WEBEM -
    ...  Adapt for shared FHS
    ...  - 03.10.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26084 - [5G][HW file removal] Implement HW file removal in
    ...  SBTS_SBTS_SBTS_SBTS__STATE__Site_Reset_from_WEBEM
    ...  - 23.10.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26298 - [5G] Add proper description for HWF Feature.
	...  - 15.04.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27281 - [5G] ALL TESTS: Reduce the number of ssh connections in
	...  Hardware File Removal mechanism + restore 1 time orig
	...  - 18.04.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27212 -
	...  [5G][DSS alarms]Add wait_for_alarm_clear because DSS alarms are not cleared in current timer - 4xSBTS
	...  - 05.07.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27686 - Port eCPRI FID16 exception
	...  - 22.07.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27760 - Align BTS list Hardware File Teardown with requested list
	...  - 23.07.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27803 -
	...  [CNI-127210] [Part 1] DSS LTE EXPECTED alarms check removal SBTS_* TCs
    ...  - 19.08.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27945 - [CNI-127210] IGNORE alarm(w/o CNI) in TCs SBTS, both TC specific
    ...  IGNORED and COMMON ADMIN IGNORED - 4xSBTS part
    ...  - 26.09.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28126 - [5G] CNI : 131510 - Classical - Part 1 - Graceful cell shutdown
    ...  - 14.10.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28092 - [REFACTORING][GENERIC_TC] NRL &NR_SBTS Site Reset to generic
    ...  SBTS SBTS BTS1 BTS2 Site Reset
    ...  - 10.12.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28344 - Update SBTS_SBTS__STATE__BTS1_BTS2_Site_Reset_from_WEBEM to
    ...  check the status of the dedicated modules on the peer BTS when performing the site reset from the primary BTS
    ...  - 17.11.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29404 - Site reset - generic test after CB012446 in trunk
    ...  - 21.01.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30401 - Site Reset - increase wait for LMP not pingable after Site Reset
    ...  - 22.01.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30391 - Need to include KPI list in generic site reset test same as in
    ...  SBTS_SBTS__STATE__Site_Reset_from_WEBEM_force_primary_link
    ...  - 29.01.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30419 - Adapt SBTS_SBTS__SWM__RU_SW_Upgrade and other tests impacted by
    ...  CB013031 with TAF-5240
    ...  - 03.03.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30579 - Check basic TA KWs RF 8 AXEGHA ORAN-ECPRI impact
    ...  - 23.03.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30664 - Bug in robot SBTS_SBTS_SBTS_SBTS__STATE__Site_Reset_from_WEBEM
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...  .. image:: https://gitlabe1.ext.net.nokia.com/panda-docs/hran_doc/-/blob/master/testsuite/RFS_SOAM/
    ...  TAT-25420_SBTS_SBTS_SBTS_SBTS__STATE_Site_Reset_from_WEBEM.png

    Set Tags    CA-STATE    OWNER-maria.toma@nokia.com   AUTHOR-anca.tatar@nokia.com    PHASE-QT    SW-SBTS23R4

    TC Preconditions
    Configure Hardware File
    Step 1: Check initial all BTS state
    Step 2: Check initial all BTS alarms
    Step 3: Check CB007447 feature settings
    Step 4: Get all BTS RMOD and CELL mapping info
    FOR  ${CYCLE}  IN RANGE  1  ${REPEAT_COUNTER}+1
        Log  ==============================================================================  console=True
        Log  Start Cycle ${CYCLE} of ${REPEAT_COUNTER}  console=True
        Log  ==============================================================================  console=True
        Step 4: Perform BTS Site Reset for iteration ${CYCLE}
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

    IF  '${BTS_LIST}' != 'ALL'    Check BTS list
    Log  ====================================================  console=True
    Log  BTS label list selected for reset operation: ${BTS_label_list}  console=True
    Log  BTS alias list selected for reset operation: ${BTS_alias_list}  console=True
    Log  ====================================================  console=True

    Check BTS Primary Link list
    Check KPI label list
    Check KPI value list

Check BTS list

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

Check KPI label list
    ${RESET_SITE_KPI_official_list}=  Create List  kpi1a  kpi1b  kpi1c

    ${RESET_SITE_KPI_list_strip}=  Replace String  ${KPI_LIST}  ${SPACE}  ${EMPTY}
    ${RESET_SITE_KPI_list}=  Split String  ${RESET_SITE_KPI_list_strip}  ,
    ${KPI_label_check}=  Set Variable  True
    ${KPI_invalid_label_list}=  Create List
    ${KPI_request_label_list}=  Create List
    ${KPI_request_alias_list}=  Create List

    FOR  ${kpi}  IN  @{RESET_SITE_KPI_list}
        ${KPI_label_check}=  Set Variable If  '${kpi}' not in ${RESET_SITE_KPI_official_list}
        ...  False  ${KPI_label_check}
        IF  '${kpi}' not in ${RESET_SITE_KPI_official_list}
            Append To List  ${KPI_invalid_label_list}  ${kpi}
        ELSE
            Append To List  ${KPI_request_label_list}  ${kpi}
        END
    END

    IF  '${KPI_label_check}' == 'False'
        Log Long String  Following selected KPI are not valid: ${KPI_invalid_label_list}.
        ...  Please select values for test argument \${KPI_LIST} from
        ...  official Reset Site KPI list: ${RESET_SITE_KPI_official_list}
        ...  or let default value: kpi1a  console=True
        Fail  Improper value for argument!
    END

    Set Test Variable  ${RESET_SITE_KPI_list}  ${KPI_request_label_list}
    ${RESET_SITE_KPI_count}=  Get Length  ${RESET_SITE_KPI_list}
    Set Test Variable  ${RESET_SITE_KPI_count}

Check KPI value list
    FOR  ${item}  IN  @{BTS_alias_list}
        Get and check BTS KPI values  ${item}
    END

Get and check BTS KPI values
    [Arguments]  ${alias}

    ${label}=  Get From Dictionary  ${BTS_alias_label_dict}  ${alias}
    ${BTS_RESET_WRN_THR_LIST}=  Set Variable  ${${label}_RESET_WRN_THR_LIST}
    ${BTS_RESET_WRN_THR_list_strip}=  Replace String  ${BTS_RESET_WRN_THR_LIST}  ${SPACE}  ${EMPTY}
    ${RESET_SITE_KPI_values_list}=  Split String  ${BTS_RESET_WRN_THR_list_strip}  ,
    ${RESET_SITE_KPI_values_count}=  Get Length  ${RESET_SITE_KPI_values_list}

    IF  ${RESET_SITE_KPI_values_count} != ${RESET_SITE_KPI_count}
        Log Long String  Number of KPI values set for test argument \${${label}_RESET_WRN_THR_LIST}
        ...  is not aligned with number of selected KPI for
        ...  Reset Site operation. Please align values for \${${label}_RESET_WRN_THR_LIST}
        ...  according to \${KPI_LIST} info or let default value:
        ...  600!  console=True
        Fail  Improper value for argument!
    END

Check RM CPRI CB007447 validity
    [Arguments]    ${shared_RMOD_sn_list}

    IF    '${CB007447_SHARED_RM_SN_EXCEPTIONS_LIST} '==' '    RETURN

    ${CB007447_SHARED_RM_SN_EXCEPTIONS_LIST_strip}=  Replace String  ${CB007447_SHARED_RM_SN_EXCEPTIONS_LIST}  ${SPACE}  ${EMPTY}
    ${CB007447_SHARED_RM_SN_EXCEPTIONS_LIST_split}=  Split String  ${CB007447_SHARED_RM_SN_EXCEPTIONS_LIST}  ,
    ${CB007447_SHARED_RM_SN_EXCEPTIONS_check}=  Set Variable  True
    ${CB007447_SHARED_RM_SN_EXCEPTIONS_invalide_list}=  Create List

    FOR  ${item}  IN  @{CB007447_SHARED_RM_SN_EXCEPTIONS_LIST_split}
        ${CB007447_SHARED_RM_SN_EXCEPTIONS_check}=  Set Variable If
        ...  '${item}' not in ${shared_RMOD_sn_list}  False  ${CB007447_SHARED_RM_SN_EXCEPTIONS_check}
        IF  '${item}' not in ${shared_RMOD_sn_list}    Append To List  ${CB007447_SHARED_RM_SN_EXCEPTIONS_invalide_list}  ${item}
    END

    IF  '${CB007447_SHARED_RM_SN_EXCEPTIONS_check}' == 'False'
        Log  Following selected shared RM serial number values are not valid: ${CB007447_SHARED_RM_SN_EXCEPTIONS_invalide_list}.
        ...  console=True
        Log  Please select values for test argument \${CB007447_SHARED_RM_SN_EXCEPTIONS_LIST} from configured shared RM: ${shared_RMOD_sn_list}
        ...  console=True
        Fail  Improper value for argument!
    END

Configure Hardware File
    IF    '${SWCONFIG_CHANGE_FLAG}' == 'False'    RETURN
    FOR  ${alias}  IN  @{BTS_alias_list}
        Set HWF Flags  swconfig_flag_action=${SWCONFIG_FLAG_ACTION}  swconfig_flag_list=${SWCONFIG_FLAG_LIST}  alias=${alias}
    END

Step ${index}: Check CB007447 feature settings
    [Documentation]
    ...  Check CB007447 feature settings on BTS

    Log  Step ${index}: Check CB007447 feature settings on BTS  console=True

    FOR  ${alias}  IN  @{alias_list}
        Log  Get CB007447 feature settings on BTS ${alias}  console=True
        ${actCpriLinkRecovery_initial}  ${actSyncLinkSwitchover_initial}
        ...  ${cpriSyncBreakTime_initial}  ${stickToSyncSourcePeriod_initial}=
        ...  Get feature CB007447 info  ${alias}

        ${condition_enabled}=  Evaluate
        ...  '${actCpriLinkRecovery_initial}' == 'true' and '${actSyncLinkSwitchover_initial}' == 'true'

        IF  ${condition_enabled}
            Log  BTS ${alias} CB007447 feature status: Enabled  console=True
        ELSE
            Log  BTS ${alias} CB007447 feature status: Disabled  console=True
        END
        Set Test Variable  ${${alias}_CB007447_status}  ${condition_enabled}

        IF  ${PM_Counters_Check} and ${${alias}_CB007447_status} and not ${single_BTS}

            Set Test Variable  ${${alias}_stickToSyncSourcePeriod_initial}  ${stickToSyncSourcePeriod_initial}
            Set Test Variable  ${${alias}_cpriSyncBreakTime_initial}  ${cpriSyncBreakTime_initial}
            Set Test Variable  ${${alias}_actCpriLinkRecovery_initial}  ${actCpriLinkRecovery_initial}
            Set Test Variable  ${${alias}_actSyncLinkSwitchover_initial}  ${actSyncLinkSwitchover_initial}

            Set feature CB007447 on BTS  alias=${alias}
            ...  cpriSyncBreakTime_value=${cpriSyncBreakTime}
            ...  stickToSyncSourcePeriod_value=${stickToSyncSourcePeriod}
            ...  actCpriLinkRecovery_value=${actCpriLinkRecovery_initial}
            ...  actSyncLinkSwitchover_value=${actSyncLinkSwitchover_initial}
            Check initial mt param   ${alias}  mtSbtsSfpBbmodLane
            Check initial mt param   ${alias}  mtSbtsSfpSmodLane

        END

    END

    ${CB007447_RMOD_excepted_sns}=  Create Dictionary
    ...  exception_for_CB007447_eligible=${CB007447_SHARED_RM_SN_EXCEPTIONS_LIST}
    Set Test Variable  ${CB007447_RMOD_excepted_sns}

    ${CB007447_exceptions_for_dependency_rule}=  Set RMOD PrimaryLink Switch Behavior Exceptions For CPRI RMOD
    ...  rmod_sn_string=${CB007447_SHARED_RM_SN_EXCEPTIONS_LIST}
    Set Test Variable  ${CB007447_exceptions_for_dependency_rule}

Set RMOD PrimaryLink Switch Behavior Exceptions For CPRI RMOD
    [Arguments]    ${rmod_sn_string}

    IF    '${rmod_sn_string} '==' '    RETURN    &{Empty}
    ${sharing_type_protocol} =  Create List  SHARED_DEDICATED  ('CPRI_no_CB007447',)
    ${excepted_CPRI_RMOD_from_CB007447}=  Create Dictionary  ${rmod_sn_string}  ${sharing_type_protocol}
    RETURN    ${excepted_CPRI_RMOD_from_CB007447}

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

    ${wait_for_alarm_clear}=  Set Variable If  '${when}' == 'final'  15 min  5 min
    Log  Step ${index}: Check ${when} all BTS alarms  console=True
    FOR  ${alias}  IN  @{alias_list}
        Log  ***** Check ${when} BTS ${alias} alarms *****  console=True
        Get and Check Alarms SOAM  alias=${alias}  expected_alarms=@{EMPTY}
        ...  ignored_alarms=${test_alarms_list['${alias.upper()}_IGNORED_ALARMS']}
        ...  critical_alarms=${test_alarms_list['${alias.upper()}_CRITICAL_ALARMS']}
        ...  wait_for_alarm_clear=${wait_for_alarm_clear}
        Log  BTS ${alias} site - expected, ignored and critical alarms checked  console=True
    END

Step ${index}: Get all BTS RMOD and CELL mapping info
    [Documentation]
    ...  Get all BTS RMOD and CELL mapping info

    Log  Step ${index}: Get all BTS RMOD and CELL mapping info  console=True

    ${RM_sn_bts-alias_dict}  ${shared_RM_sn_list}  ${dedicated_RM_sn_list}=  Admin Get RM sn bts-alias info dict
    Set Test Variable  ${RM_sn_bts-alias_dict}
    Set Test Variable  ${shared_RM_sn_list}

    FOR  ${alias}  IN  @{alias_list}

        ${BTS_RM_alias_connection_dict}  ${BTS_shared_RM_id_sn_dict}  ${BTS_dedicated_RM_id_sn_dict}  ${BTS_shared_RM_sn_id_dict}
        ...  ${BTS_dedicated_RM_sn_id_dict}=  Admin Get shared and dedicated module info for BTS  RMOD  ${alias}
        Set Test Variable  ${${alias}_dedicated_RM_id_sn_dict}  ${BTS_dedicated_RM_id_sn_dict}

        Get BTS CELL list by RAT  ${alias}

        Get BTS MODULE LANE info dict  RMOD  ${alias}
        Set Test Variable  ${${alias}_MODULE_LANE_dict}  ${MODULE_LANE_dict}

    END

    ${BTS_alias_RMOD_sn_dict}  ${RMOD_sn_BTS_alias_dict}  ${shared_RMOD_sn_list}  ${dedicated_RMOD_sn_list}=
    ...  Get all BTS RMOD sharing info
    Check RM CPRI CB007447 validity  ${shared_RMOD_sn_list}
    Get all SMOD board types
    Get all BTS SMOD BBMOD list

Step ${index}: Perform BTS Site Reset for iteration ${CYCLE}
    [Documentation]
    ...  Perform BTS Site Reset

    Log  Step ${index}: Perform BTS Site Reset for iteration ${CYCLE}  console=True
    Set Test Variable  ${CYCLE}
    FOR  ${alias}  IN  @{BTS_alias_list}
        Set shared fronthaul modules Primary Link before BTS reset  ${alias}
        Get RESET timestamp info  start
        Log  Get BTS impact info due to ${BTS_alias_label_dict}[${alias}] Site Reset  console=True
        Get BTSs impact info due to Site Reset
        ...  alias=${alias}  cb007447_status=${${alias}_CB007447_status}
        ...  CB007447_EXCEPTIONS_rule=${CB007447_exceptions_for_dependency_rule}
        ...  CB007447_EXCEPTIONS_sn=${CB007447_RMOD_excepted_sns}

        Log  Perform ${BTS_alias_label_dict}[${alias}] Site Reset  console=True
        Perform BTS Site Reset  ${alias}
        Get RESET timestamp info  end
        Save ims file for checks  ${peer_aliases}
        Check peer BTS states and alarms during Site Reset from IMS  ${alias}  ${peer_aliases}
        ...  ${date_timestamp_start_UTC}  ${date_timestamp_end_UTC}
        Check all BTS reset behavior based on IMS info  ${alias}  ${peer_aliases}
        Check peer BTS CPRI RMOD PM counters for CB007447  ${peer_aliases}
        Get and check BTS KPI info from IMS file  ${alias}
    END

Check BTS Primary Link list

    IF    '${BTS_PRIMARY_LINK_LIST} ' == ' '    RETURN

    ${BTS_PRIMARY_LINK_LIST_strip}=  Replace String  ${BTS_PRIMARY_LINK_LIST}  ${SPACE}  ${EMPTY}
    ${BTS_PL_LIST}=  Split String  ${BTS_PRIMARY_LINK_LIST_strip}  ,
    ${BTS_PL_check}=  Set Variable  True
    ${BTS_PL_invalid_label_list}=  Create List
    ${BTS_PL_request_label_list}=  Create List
    ${BTS_PL_request_alias_list}=  Create List

    ${label_list}=  Get Dictionary Values  ${BTS_alias_label_dict}  False

    FOR  ${item}  IN  @{BTS_PL_LIST}

        ${BTS_PL_check}=  Set Variable If  '${item}' not in ${label_list}  False  ${BTS_PL_check}

        IF  '${item}' not in ${label_list}
            Append To List  ${BTS_PL_invalid_label_list}  ${item}
        ELSE
            Append To List  ${BTS_PL_request_label_list}  ${item}
        END

    END

    IF  '${BTS_PL_check}' == 'False'
        Log Long String  Following selected BTS are not valid: ${BTS_PL_invalid_label_list}.
        ...  Please select values for test argument
        ...  \${BTS_PRIMARY_LINK_LIST} from configured BTS: ${label_list} or let default value (empty)   console=True
        Fail  Improper value for argument!
    END

    ${BTS_PL_LIST_length}=  Get Length  ${BTS_PL_LIST}

    IF  ${BTS_PL_LIST_length} == 1
        Create BTS Primary Link info dict  ${BTS_alias_list}  ${BTS_PL_LIST}
        RETURN
    END

    ${BTS_LIST_length}=  Get Length  ${BTS_alias_list}

    IF  ${BTS_PL_LIST_length} != ${BTS_LIST_length}
        Log Long String  Number of BTS for primary link set for test argument \${BTS_PRIMARY_LINK_LIST}
        ...  is not aligned with number of selected BTS
        ...  for power off/on operations. Please align values for \${BTS_PRIMARY_LINK_LIST}
        ...  according to argument description!  level=ERROR
        Fail  Improper value for argument!
    END

    Create BTS Primary Link info dict  ${BTS_alias_list}  ${BTS_PL_LIST}

Create BTS Primary Link info dict
    [Arguments]  ${BTS_alias_list}  ${BTS_PL_LIST}

    ${BTS_alias_BTS_PL_label_dict}=  Create Dictionary
    ${BTS_PL_LIST_length}=  Get Length  ${BTS_PL_LIST}

    FOR  ${index}  ${alias}  IN ENUMERATE  @{BTS_alias_list}

        IF  ${BTS_PL_LIST_length} == 1
            ${BTS_PL_label}=    Get From List  ${BTS_PL_LIST}  0
        ELSE
            ${BTS_PL_label}=    Get From List  ${BTS_PL_LIST}  ${index}
        END

        Set To Dictionary  ${BTS_alias_BTS_PL_label_dict}  ${alias}  ${BTS_PL_label}

    END

    Set Test Variable  ${BTS_alias_BTS_PL_label_dict}

Set shared fronthaul modules Primary Link before BTS reset
    [Arguments]  ${alias}

    [Documentation]
    ...  Set shared fronthaul modules (FHS, RMOD) Primary Link if needed

    Log  Set shared fronthaul modules Primary Link before BTS ${alias} reset   console=True

    IF  '${BTS_PRIMARY_LINK_LIST}' == ''
        Log  - test action will be performed with existing shared fronthaul modules Primary Link configuration
        ...  console=True
        RETURN
    END

    ${BTS_PL_label}=  Get From Dictionary  ${BTS_alias_BTS_PL_label_dict}  ${alias}
    ${BTS_PL_alias}=  Get From Dictionary  ${BTS_label_alias_dict}  ${BTS_PL_label}

    ${BTS_MOD_id_list_dict}=  Create Dictionary  Equipment_enabled=${${alias}_MOD_id_list}
    ${BTS_MOD_equipment_dict}  ${BTS_MOD_detailed_equipment_dict}=
    ...  Get BTS equipment connected by Cablink
    ...  ${BTS_MOD_id_list_dict}
    ...  ${alias}
    ...  Max_equipment_level=${1}
    ...  Reset_dependency_rules=${Reset_dependency_rules}

    ${BTS_MOD_FHS_SN_list}=  Get From dictionary
    ...  ${BTS_MOD_detailed_equipment_dict}
    ...  SHARED_FHS_CPRI_enabled_SN

    ${BTS_MOD_RMOD_SN_LIST}=  Get Combined List From dictionary
    ...  ${BTS_MOD_detailed_equipment_dict}
    ...  SHARED_RMOD_CPRI_enabled_SN  SHARED_RMOD_ECPRI_enabled_SN  SHARED_RMOD_ECPRI_NETCONF_enabled_SN

    IF  ${BTS_MOD_FHS_SN_list}
        Log  - test action will be performed with shared FHSs Primary Link set on ${BTS_PL_label}  console=True
        Set Primary Link status based on linkModeSynchronization  module_type=FHS
        ...  procedure_for_Primary_Link_set=${SET_PRIMARY_LINK_PROCEDURE}
        ...  alias=${BTS_PL_alias}  wait_for_Primary_Link_set=${SET_PRIMARY_LINK_TIME}
        ...  module_SN_list=${BTS_MOD_FHS_SN_list}
    END

    IF  ${BTS_MOD_RMOD_SN_LIST}
        Log  - test action will be performed with shared RMODs Primary Link set on ${BTS_PL_label}  console=True
        Set Primary Link status based on linkModeSynchronization  module_type=RMOD
        ...  procedure_for_Primary_Link_set=${SET_PRIMARY_LINK_PROCEDURE}
        ...  alias=${BTS_PL_alias}  wait_for_Primary_Link_set=${SET_PRIMARY_LINK_TIME}
        ...  module_SN_list=${BTS_MOD_RMOD_SN_LIST}
    END

Get BTSs impact info due to Site Reset
    [Arguments]  ${alias}  ${cb007447_status}  ${CB007447_EXCEPTIONS_sn}=&{Empty}  ${CB007447_EXCEPTIONS_rule}=&{Empty}

    ${dependency_rules_dict}  ${exceptions_dict}=  Select dependency rule and exceptions based on cb007447 status
    ...  ${cb007447_status}  ${CB007447_EXCEPTIONS_rule}

    ${SMOD_BBMOD_id_dict}=  Create Dictionary  Equipment_reset=${${alias}_MOD_id_list}
    ${TL_detailed_equipment_dict}=  Get Testline equipment connected by Cablink
    ...  ${SMOD_BBMOD_id_dict}
    ...  ${alias}
    ...  ${alias_list}
    ...  Reset_dependency_rules=${dependency_rules_dict}
    ...  CPRI_SN_EXCEPTIONS=${exceptions_dict}
    ...  ECPRI_SN_EXCEPTIONS=&{Empty}
    ...  ECPRI_NETCONF_SN_EXCEPTIONS=&{Empty}
    ...  OBSAI_SN_EXCEPTIONS=&{Empty}
    ...  CB007447_EXCEPTIONS=${CB007447_EXCEPTIONS_sn}
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
    Get Site Reset Impact On peer BTS  alias=${alias}  peer_aliases=${peer_aliases}
    ...  TL_detailed_equipment_dict=${TL_detailed_equipment_dict}
    Get alarms during Site Reset on peer BTS  peer_aliases=${peer_aliases}
    ...  TL_detailed_equipment_dict=${TL_detailed_equipment_dict}

Get Site Reset impact on peer BTS
    [Arguments]    ${alias}  ${peer_aliases}  ${TL_detailed_equipment_dict}

    FOR  ${peer_alias}  IN  @{peer_aliases}

        ${detailed_dependent_peer_equipment_dict}=  Get From Dictionary  ${TL_detailed_equipment_dict}  ${peer_alias}
        ${expected_peer_BTS_enabled_shared_RMOD_id_list}=  Get Combined List From Dictionary
        ...  ${detailed_dependent_peer_equipment_dict}
        ...  SHARED_RMOD_CPRI_enabled  SHARED_RMOD_ECPRI_enabled  SHARED_RMOD_ECPRI_NETCONF_enabled  SHARED_RMOD_OBSAI_enabled
        ${expected_peer_BTS_enabled_dedicated_RMOD_id_list}=  Get Combined List From Dictionary
        ...  ${detailed_dependent_peer_equipment_dict}
        ...  DEDICATED_RMOD_CPRI_enabled  DEDICATED_RMOD_ECPRI_enabled  DEDICATED_RMOD_ECPRI_NETCONF_enabled  DEDICATED_RMOD_OBSAI_enabled

        # eCPRI RMOD become disabled for a very short time when losing sync and sometimes do not become disabled at all.
        # therefore avoid adding disabled eCPRI RMOD below for disabled state check
        ${expected_peer_BTS_disabled_shared_RMOD_id_list}=  Get Combined List From Dictionary
        ...  ${detailed_dependent_peer_equipment_dict}
        ...  SHARED_RMOD_CPRI_disabled  SHARED_RMOD_OBSAI_disabled
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

        ${expected_peer_BTS_CPRI_shared_RMOD_SN_list}=  Get Combined List From Dictionary
        ...  ${detailed_dependent_peer_equipment_dict}
        ...  SHARED_RMOD_CPRI_enabled_SN  SHARED_RMOD_CPRI_disabled_SN
        ${expected_peer_BTS_CPRI_shared_RMOD_7447_eligibility_list}=  Get Combined List From Dictionary
        ...  ${detailed_dependent_peer_equipment_dict}
        ...  SHARED_RMOD_CPRI_enabled_CB007447_eligible  SHARED_RMOD_CPRI_disabled_CB007447_eligible
        ${expected_peer_BTS_CPRI_shared_RMOD_7447_connected_in_list}=  Get Combined List From Dictionary
        ...  ${detailed_dependent_peer_equipment_dict}
        ...  SHARED_RMOD_CPRI_enabled_connected_in  SHARED_RMOD_CPRI_disabled_connected_in
        ${expected_peer_BTS_CPRI_shared_RMOD_for_CB007447_not_connected_in_fhs}=
        ...  Evaluate  [x!='FHS' for x in ${expected_peer_BTS_CPRI_shared_RMOD_7447_connected_in_list}]
        ${expected_peer_BTS_CPRI_shared_RMOD_for_CB007447_losing_sync_link}=  Get Combined List From Dictionary
        ...  ${detailed_dependent_peer_equipment_dict}
        ...  SHARED_RMOD_CPRI_enabled_sync_link_lost  SHARED_RMOD_CPRI_disabled_sync_link_lost
        ${expected_peer_BTS_shared_CPRI_RMOD_supporting_CB007447_losing_sync_sn}=  Filter RMOD depending on feature
        ...  elements_to_be_filtered=${expected_peer_BTS_CPRI_shared_RMOD_SN_list}
        ...  list1_containing_filtering_criteria_flags=${expected_peer_BTS_CPRI_shared_RMOD_7447_eligibility_list}
        ...  list2_containing_filtering_criteria_flags=${expected_peer_BTS_CPRI_shared_RMOD_for_CB007447_not_connected_in_fhs}
        ...  list3_containing_filtering_criteria_flags=${expected_peer_BTS_CPRI_shared_RMOD_for_CB007447_losing_sync_link}

        ${BTS_RM_alias_connection_dict}  ${BTS_shared_RM_id_sn_dict}  ${BTS_dedicated_RM_id_sn_dict}  ${BTS_shared_RM_sn_id_dict}
        ...  ${BTS_dedicated_RM_sn_id_dict}=  Admin Get shared and dedicated module info for BTS  RMOD  ${peer_alias}
        ${peer_BTS_enabled_dedicated_RMOD_list_connected_not_connected_to_reset_element}=  Get Dictionary Keys  ${BTS_dedicated_RM_id_sn_dict}
        Remove Values From List  ${peer_BTS_enabled_dedicated_RMOD_list_connected_not_connected_to_reset_element}
        ...  @{expected_peer_BTS_disabled_dedicated_RMOD_id_list}
        Append To List  ${expected_peer_BTS_enabled_dedicated_RMOD_id_list}
        ...  @{peer_BTS_enabled_dedicated_RMOD_list_connected_not_connected_to_reset_element}

        ${dedicated_RM}=  Get Dictionary Keys  ${BTS_dedicated_RM_id_sn_dict}
        ${shared_RM}=  Get Dictionary Keys  ${BTS_shared_RM_id_sn_dict}
        ${all_RMs}=  Create List  @{dedicated_RM}  @{shared_RM}

        Set Test Variable  ${expected_${peer_alias}_enabled_shared_RMOD_id_list}  ${expected_peer_BTS_enabled_shared_RMOD_id_list}
        Set Test Variable  ${expected_${peer_alias}_disabled_shared_RMOD_id_list}  ${expected_peer_BTS_disabled_shared_RMOD_id_list}
        Set Test Variable  ${expected_${peer_alias}_disabled_RMOD_id_list}  ${expected_peer_BTS_disabled_RMOD_id_list}
        Set Test Variable  ${expected_${peer_alias}_enabled_dedicated_RMOD_id_list}  ${expected_peer_BTS_enabled_dedicated_RMOD_id_list}
        Set Test Variable  ${expected_${peer_alias}_disabled_dedicated_RMOD_id_list}  ${expected_peer_BTS_disabled_dedicated_RMOD_id_list}
        Set Test Variable  ${expected_${peer_alias}_enabled_shared_FHS_id_list}  ${expected_peer_BTS_enabled_shared_FHS_id_list}
        Set Test Variable  ${expected_${peer_alias}_disabled_shared_FHS_id_list}  ${expected_peer_BTS_disabled_shared_FHS_id_list}

        Set Test Variable  ${${peer_alias}_shared_CPRI_RMOD_supporting_CB007447_losing_sync_sn}
        ...  ${expected_peer_BTS_shared_CPRI_RMOD_supporting_CB007447_losing_sync_sn}

        ${enabled_rmod_list}=  Combine Lists
        ...  ${expected_peer_BTS_enabled_shared_RMOD_id_list}  ${expected_peer_BTS_enabled_dedicated_RMOD_id_list}

        ${enabled_CELL_RM_list_not_impacted_by_x2}  ${enabled_NR_CELL_RM_list_impacted_by_x2}=
        ...  Get RMOD list all RAT Cells By Dependency Of LTEENB X2  ${enabled_rmod_list}  ${peer_alias}  ${alias}

        Set Test Variable  ${${peer_alias}_enabled_cell_list}  ${enabled_CELL_RM_list_not_impacted_by_x2}
        Set Test Variable  ${${peer_alias}_possibly_disabled_cell_list}  ${enabled_NR_CELL_RM_list_impacted_by_x2}

    END

Get RMOD list all RAT Cells By Dependency Of LTEENB X2
    [Arguments]  ${rmod_list}  ${NR_BTS_alias}  ${peer_alias}

    ${NR_CELL_list}  ${LTE_CELL_list}  ${WCDMA_CELL_list}  ${GSM_CELL_list}=  Get BTS Cells From RMOD List
    ...  ${rmod_list}  ${NR_BTS_alias}

    ${result_no_impact}=  Create List  @{LTE_CELL_list}  @{WCDMA_CELL_list}  @{GSM_CELL_list}
    ${result_impact}=  Create List
    IF    not ${NR_CELL_list}    RETURN    ${result_no_impact}    ${result_impact}

    ${NR_SA_cell_list}  ${NR_NSA_cell_list}=  Get NR Cell Deployment Type list  ${NR_CELL_list}  ${NR_BTS_alias}
    ${NR_NSA_id_list}=  Evaluate  [x['id']['internal'] for x in ${NR_NSA_cell_list}]
    Append To List  ${result_no_impact}  @{NR_SA_cell_list}

    ${LNBTS_mplane_ip_dict}=  Get mPlane IP dict  ${peer_alias}

    ${x2_connection_found}  ${number_of_x2}=  Get NRBTS X2 connections  ${NR_BTS_alias}  ${LNBTS_mplane_ip_dict}

    IF  ${x2_connection_found} and ${number_of_x2}==${1}
        Append To List  ${result_impact}  @{NR_NSA_id_list}
    ELSE
        Append To List  ${result_no_impact}  @{NR_NSA_id_list}
    END

    RETURN  ${result_no_impact}  ${result_impact}

Get mPlane IP dict
    [Arguments]  ${peer_alias}
    ${scf_path}=  coam.Get Current Scf File
    ...  local_dir_path=${BTSFiles}/SCF_temp  file_name=SCF_temp_${peer_alias}.xml  connection=${peer_alias}
    ...  export_type=configurationAndRuntimeObjects  with_auto_configured_parameters=${TRUE}
    ${mplane_ip_dn}=  Set Variable  ${None}
    ${mplane_ip_dict}=  Set Variable  ${None}
    ${cPlane_dict}=  Create Dictionary

    ${TRNSW_dn_list}=  Get All Dist Names By Pattern from SCF  pattern=/TRSNW-[\\d]+$  scf_path=${scf_path}  alias=${peer_alias}
    IF  ${TRNSW_dn_list}
        ${_}  ${cPlane_dict}=    Get Object Attributes Values From Scf
        ...  scf_path=${scf_path}  dist_name=${TRNSW_dn_list}[${0}]  list_name=cPlane
    END

    IF  ${cPlane_dict}
        ${mplane_ip_dn}=  Set Variable  ${cPlane_dict}[cPlane][${0}]
    END
    IF  '${mplane_ip_dn}'!='${None}'
        ${mplane_ip_dict}  ${_}=  Get Object Attributes Values From Scf
        ...  scf_path=${scf_path}  dist_name=${mplane_ip_dn}  p_name=localIpAddr
    END

    RETURN  ${mplane_ip_dict}

Get NRBTS X2 connections
    [Arguments]  ${NR_BTS_alias}  ${LNBTS_mplane_ip_dict}

    ${x2ParamDict}=  Create Dictionary
    ${LTEENB_list}  ${LTEENB_count}=  Get LTEENB list  ${NR_BTS_alias}
    ${number_of_x2}=  Get Length  ${LTEENB_list}

    coam.Get Current Scf File
    ...  local_dir_path=${BTSFiles}/SCF_temp  file_name=SCF_temp_${NR_BTS_alias}.xml  connection=${NR_BTS_alias}
    ...  export_type=configurationAndRuntimeObjects  with_auto_configured_parameters=${TRUE}
    scf.Load Scf  ${BTSFiles}/SCF_temp/SCF_temp_${NR_BTS_alias}.xml

    ${x2_connection_found}=  Set Variable  ${False}

    FOR  ${item}  IN  @{LTEENB_list}
        ${eNodeBId}=  scf.Get Value From Scf  dist_name=${item}  p_name=eNodeBId
        ${ipAddr}=  scf.Get Value From Scf  dist_name=${item}  p_name=ipAddr
        IF  ${LNBTS_mplane_ip_dict} and '${LNBTS_mplane_ip_dict}[localIpAddr]'=='${ipAddr}'
            ${x2_connection_found}=  Set Variable  ${True}
            BREAK
        END
    END

    RETURN  ${x2_connection_found}  ${number_of_x2}

Get BTS Cells From RMOD List
    [Arguments]  ${rmod_list}  ${peer_alias}

    ${NR_CELL_list}=  Create List
    ${LTE_CELL_list}=  Create List
    ${WCDMA_CELL_list}=  Create List
    ${GSM_CELL_list}=  Create List

    FOR  ${rmod_id}  IN  @{rmod_list}
        ${NR_CELL_RM_list}  ${LTE_CELL_RM_list}  ${WCDMA_CELL_RM_list}  ${GSM_CELL_RM_list}=
        ...  Get RM all cells from specific RAT  ${rmod_id}  ${peer_alias}
        Append To List  ${NR_CELL_list}  @{NR_CELL_RM_list}
        Append To List  ${LTE_CELL_list}  @{LTE_CELL_RM_list}
        Append To List  ${WCDMA_CELL_list}  @{WCDMA_CELL_RM_list}
        Append To List  ${GSM_CELL_list}  @{GSM_CELL_RM_list}
    END

    RETURN  ${NR_CELL_list}  ${LTE_CELL_list}  ${WCDMA_CELL_list}  ${GSM_CELL_list}

Get alarms during Site Reset on peer BTS
    [Arguments]    ${peer_aliases}  ${TL_detailed_equipment_dict}

    FOR  ${peer_alias}  IN  @{peer_aliases}

        ${detailed_dependent_peer_equipment_dict}=  Get From Dictionary  ${TL_detailed_equipment_dict}  ${peer_alias}
        ${peer_BTS_OBSAI_FHS_FID10_alarm_count}  ${peer_BTS_CPRI_FID10_1815_alarm_count}
        ...  ${peer_BTS_ECPRI_FID16_alarm_count}=
        ...  Get peer BTS alarms
        ...  ${detailed_dependent_peer_equipment_dict}  ${peer_alias}

        ${peer_SBTS_EXPECTED_ALARMS_10}=  Prepare expected alarms list
        ...  ${test_alarms_list['${peer_alias.upper()}_EXPECTED_ALARMS_10']}
        ...  ${peer_BTS_OBSAI_FHS_FID10_alarm_count}
        ${peer_SBTS_EXPECTED_ALARMS_10_1815}=  Prepare expected alarms list
        ...  ${test_alarms_list['${peer_alias.upper()}_EXPECTED_ALARMS_10_1815']}
        ...  ${peer_BTS_CPRI_FID10_1815_alarm_count}
        ${peer_SBTS_EXPECTED_ALARMS_16}=  Prepare expected alarms list
        ...  ${test_alarms_list['${peer_alias.upper()}_EXPECTED_ALARMS_16']}
        ...  ${peer_BTS_ECPRI_FID16_alarm_count}
        ${peer_SBTS_EXPECTED_ALARMS_10_1815_16}=  Combine Lists  ${peer_SBTS_EXPECTED_ALARMS_10}  ${peer_SBTS_EXPECTED_ALARMS_10_1815}
        ...  ${peer_SBTS_EXPECTED_ALARMS_16}
        Set Test Variable  ${${peer_alias}_OBSAI_FHS_FID10_alarm_count}  ${peer_BTS_OBSAI_FHS_FID10_alarm_count}
        Set Test Variable  ${${peer_alias}_CPRI_FID10_1815_alarm_count}  ${peer_BTS_CPRI_FID10_1815_alarm_count}
        Set Test Variable  ${${peer_alias}_ECPRI_FID16_alarm_count}  ${peer_BTS_ECPRI_FID16_alarm_count}
        Set Test Variable  ${${peer_alias}_EXPECTED_ALARMS_10_1815_16}  ${peer_SBTS_EXPECTED_ALARMS_10_1815_16}

    END

Get peer BTS alarms
    [Arguments]  ${detailed_dependent_peer_equipment_dict}  ${alias}

    ${RMOD_OBSAI_FHS_list}=  Get Combined List From Dictionary  ${detailed_dependent_peer_equipment_dict}
    ...  SHARED_RMOD_OBSAI_disabled  DEDICATED_RMOD_OBSAI_disabled  SHARED_FHS_CPRI_disabled
    ${RMOD_CPRI_list}=  Get Combined List From Dictionary  ${detailed_dependent_peer_equipment_dict}
    ...  SHARED_RMOD_CPRI_disabled  DEDICATED_RMOD_CPRI_disabled
    ${RMOD_ECPRI_ECPRI_NETCONF_list}=  Get Combined List From Dictionary  ${detailed_dependent_peer_equipment_dict}
    ...  SHARED_RMOD_ECPRI_disabled  DEDICATED_RMOD_ECPRI_disabled
    ...  SHARED_RMOD_ECPRI_NETCONF_disabled  DEDICATED_RMOD_ECPRI_NETCONF_disabled

    ${OBSAI_FHS_FID10_alarm_count}=  Get Length  ${RMOD_OBSAI_FHS_list}
    ${CPRI_FID10_1815_alarm_count}=  Get Length  ${RMOD_CPRI_list}
    ${ECPRI_FID16_alarm_count}=  Get Length  ${RMOD_ECPRI_ECPRI_NETCONF_list}

    FOR  ${item}  IN  @{RMOD_ECPRI_ECPRI_NETCONF_list}
        ${RMOD_param}=  Get Parameters For  class_name=RMOD  id_num=${item}  connection=${alias}
        IF  not('${RMOD_param['productName']}' in ${RMOD_ECPRI_fid16_exceptions})    CONTINUE
        ${ECPRI_FID16_alarm_count}=  Evaluate  ${ECPRI_FID16_alarm_count} - ${1}
    END

    RETURN  ${OBSAI_FHS_FID10_alarm_count}  ${CPRI_FID10_1815_alarm_count}  ${ECPRI_FID16_alarm_count}

Select dependency rule and exceptions based on cb007447 status
    [Arguments]    ${cb007447_status}  ${CB007447_EXCEPTIONS}

    ${dependency_rules_dict_name}=  Set Variable If  ${cb007447_status}
    ...  Reset_dependency_rules_CB007447  Reset_dependency_rules
    ${dependency_rules_dict}=  Get Variable Value  ${${dependency_rules_dict_name}}

    ${exceptions}=  Set Variable If  ${cb007447_status}  ${CB007447_EXCEPTIONS}  &{Empty}
    RETURN    ${dependency_rules_dict}  ${exceptions}

Get all BTS SMOD BBMOD list

    FOR  ${alias}  IN  @{alias_list}

       ${SMOD_id_list}=  Get Ids For All  class_name=SMOD  connection=${alias}
       ${BBMOD_id_list}=  Get Ids For All  class_name=BBMOD  connection=${alias}
       ${BTS_MOD_id_list}=  Combine Lists  ${SMOD_id_list}  ${BBMOD_id_list}
       Set Test Variable  ${${alias}_MOD_id_list}  ${BTS_MOD_id_list}

    END

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]
    ...  Cells state is checked according to operationalState attribute
    ...  Check if number of configured cells and radio modules in SCF are properly mapping on BTS running view.
    ...  Also check RMs operationalState

    [Timeout]  30 min
    Log  Step ${index}: Check final number and state of Cells and RMs  console=True
    RFS Test Case Final Checks

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

Get RM all cells from specific RAT
    [Arguments]  ${RM_id}  ${alias}
    ${CELL_RM_list}=  Get Cell Mapping By Module Id  module_id=${RM_id}  connection=${alias}
    ${NR_CELL_RM_list}=  Create List
    ${LTE_CELL_RM_list}=  Create List
    ${WCDMA_CELL_RM_list}=  Create List
    ${GSM_CELL_RM_list}=  Create List
    FOR  ${item}  IN  @{${alias}_CELL_list}
        IF  '${item}' in ${CELL_RM_list} and '${item}' in ${${alias}_NR_CELL_list}    Append To List  ${NR_CELL_RM_list}  ${item}
        IF  '${item}' in ${CELL_RM_list} and '${item}' in ${${alias}_LTE_CELL_list}    Append To List  ${LTE_CELL_RM_list}  ${item}
        IF  '${item}' in ${CELL_RM_list} and '${item}' in ${${alias}_WCDMA_CELL_list}    Append To List  ${WCDMA_CELL_RM_list}  ${item}
        IF  '${item}' in ${CELL_RM_list} and '${item}' in ${${alias}_GSM_CELL_list}    Append To List  ${GSM_CELL_RM_list}  ${item}
    END
    Sort List  ${NR_CELL_RM_list}
    Sort List  ${LTE_CELL_RM_list}
    Sort List  ${WCDMA_CELL_RM_list}
    Sort List  ${GSM_CELL_RM_list}
    RETURN  ${NR_CELL_RM_list}  ${LTE_CELL_RM_list}  ${WCDMA_CELL_RM_list}  ${GSM_CELL_RM_list}

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
    [Arguments]  ${alias}  ${peer_aliases}

    Log  /n***** Check all BTS reset behavior based on IMS info *****  console=True
    Get and check BTS RESET info from IMS file  expected_reset_number=1  alias=${alias}
    ...  start_point_timestamp_UTC=${date_timestamp_start_UTC}  end_point_timestamp_UTC=${date_timestamp_end_UTC}
    FOR  ${other_alias}  IN  @{peer_aliases}
        Get and check BTS RESET info from IMS file  expected_reset_number=0  alias=${other_alias}
        ...  start_point_timestamp_UTC=${date_timestamp_start_UTC}  end_point_timestamp_UTC=${date_timestamp_end_UTC}
    END

Get and check BTS KPI info from IMS file
    [Documentation]
    ...  Get and check BTS KPI info from IMS file
    [Arguments]  ${alias}

    Log  /n***** Get and check KPI info from IMS file *****  console=True
    ${label}=  Get From Dictionary  ${BTS_alias_label_dict}  ${alias}
    ${kpi_name_delta_dict}=  Get and check KPI info from IMS file  kpi_names=${KPI_LIST}  kpi_thresholds=${${label}_RESET_WRN_THR_LIST}
    ...  alias=${alias}  start_point_timestamp_UTC=${date_timestamp_start_UTC}  end_point_timestamp_UTC=${date_timestamp_end_UTC}

    FOR  ${kpi}  IN  @{RESET_SITE_KPI_list}

        ${kpi_delta_list}=  Get From Dictionary  ${kpi_name_delta_dict}  ${kpi}

        Export KPI Results to File  alias=${alias}  obj=BTS  obj_type=SBTS  obj_id=${label}  action_1=Site_Reset  kpi_reported_1=${kpi}
        ...  event_value_1=${kpi_delta_list[0]}  cycle=${CYCLE}  source_info=ims

    END

Perform BTS Site Reset
    [Arguments]  ${alias}
    Set Test Variable  ${RMOD_state_enabled_check}  operationalState=${Enabled_}, blockingState=${Unblocked_}
    Set Test Variable  ${RMOD_state_enabled}  operationalState=Enabled, blockingState=Unblocked
    ${RMOD_state_enabled_dict}=  Create Dictionary  operationalState=${Enabled_}
    Set Test Variable  ${RMOD_state_enabled_dict}
    ${RMOD_state_disabled_dict}=  Create Dictionary  operationalState=${Disabled_}
    Set Test Variable  ${RMOD_state_disabled_dict}
    ${FHS_state_enabled_dict}=  Create Dictionary  operationalState=${Enabled_}
    Set Test Variable  ${FHS_state_enabled_dict}
    ${FHS_state_disabled_dict}=  Create Dictionary  operationalState=${Disabled_}
    Set Test Variable  ${FHS_state_disabled_dict}
    Set Test Variable  ${CELL_state_enabled_check}  operationalState=${Enabled_}, blockingState=${Unblocked_}
    Set Test Variable  ${CELL_state_enabled}  operationalState=Enabled, blockingState=Unblocked
    ${CELL_state_enabled_dict}=  Create Dictionary  operationalState=${Enabled_}  blockingState=${Unblocked_}
    Set Test Variable  ${CELL_state_enabled_dict}

    IF  ${PM_Counters_Check} and ${${alias}_CB007447_status} and not ${single_bts}
        Synchronize link break event to PM generation  ${alias}  mtSbtsSfpSmodLane  60000
    END
    Log  Perform "Reset Site" operation on ${BTS_alias_label_dict}[${alias}] from Admin  console=True
    Get Current Time  bts_reset
    RFS Site Reset  connection=${alias}  graceful_cell_shutdown=${GRACEFUL_CELL_SHUTDOWN}
    IF  '${PM_Counters_Check}' == 'True'    Get epoch time after Reset Site

    ${BTS_LMP_IP_address}=  Set Variable  ${${alias.upper()}}[${alias.upper()}_TECH_IP_ADDRESS]
    ${remote_host_ip}=  Set Variable If  '${alias}' == 'Master'  None  ${${alias.upper()}}[${alias.upper()}_PC_IP_ADDRESS]
    Wait For Target To Be Not Reachable TAF  hostname=${BTS_LMP_IP_address}  remote_host=${remote_host_ip}  timeout=360

    Log Long String  ***** Check ${BTS_alias_label_dict}[${alias}] status and alarms after "Reset Site" operation
    ...  on ${BTS_alias_label_dict}[${alias}] *****  console=True
    Log  Check ${BTS_alias_label_dict}[${alias}] status:  console=True

    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_bts_reset}  ${BTS_MAX_WAIT_TIME}
    Admin Check BTS Procedural and Blocking states  ${OnAir_}  ${Unblocked_}  ${remained_MAX_WAIT_TIME}  ${alias}
    Log  ${BTS_alias_label_dict}[${alias}] site - proceduralState: OnAir, blockingState: Unblocked, as expected!  console=True

    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_bts_reset}  ${BTS_MAX_WAIT_TIME}
    Admin Check BTS RAT cells expected states  ${CELL_state_enabled_check}  ${alias}  ${remained_MAX_WAIT_TIME}
    Log  All ${BTS_alias_label_dict}[${alias}] cell(s) status:\n - ${CELL_state_enabled}  console=True
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_bts_reset}  ${BTS_MAX_WAIT_TIME}
    Check cells availability status online  ${alias}  ${remained_MAX_WAIT_TIME}

    Log  Check ${BTS_alias_label_dict}[${alias}] alarms:  console=True
    Get and Check Alarms SOAM  alias=${alias}  expected_alarms=@{EMPTY}
    ...  ignored_alarms=${test_alarms_list['${alias.upper()}_IGNORED_ALARMS']}
    ...  critical_alarms=${test_alarms_list['${alias.upper()}_CRITICAL_ALARMS']}
    Log  ${BTS_alias_label_dict}[${alias}] site - expected, ignored and critical alarms checked  console=True

Save ims file for checks
      [Arguments]  ${peer_aliases}

      FOR  ${alias}  IN  @{peer_aliases}
          ${ims_file_path}=  Admin Collect IMS file with timestamp  folder_path=${Test Results Dir}/IMS/${alias}  alias=${alias}
          Set Test Variable  ${${alias}_ims_file_path}  ${ims_file_path}
      END

Get shared FHS RMOD list
    [Arguments]  ${FHS_list}  ${alias}
    ${shared_FHS_RMOD_list}=  Create List
    FOR  ${item}  IN  @{FHS_list}
        ${RMOD_list}=  Get RMOD Mapping By FHS Id  ${item}  ${alias}
        Append To List  ${shared_FHS_RMOD_list}  @{RMOD_list}
    END
    ${shared_FHS_RMOD_list}=  Remove Duplicates  ${shared_FHS_RMOD_list}
    RETURN  ${shared_FHS_RMOD_list}

Get RMOD Mapping By FHS Id
    [Arguments]   ${FHS_id}  ${alias}
    ${RMOD_list}=  Create List
    ${CABLINK_list}=  Get Parameters For All  class_name=CABLINK  connection=${alias}
    FOR  ${item}  IN  @{CABLINK_list}
        ${CABLINK_id}=  Get From Dictionary  ${item}  id
        ${firstEndpointDN_FHS_R}=  Run Keyword And Return Status  Should Contain  ${item.firstEndpointDN}  FHS_R
        ${secondEndpointDN_RMOD_R}=  Run Keyword And Return Status  Should Contain  ${item.secondEndpointDN}  RMOD_R
        IF  ${firstEndpointDN_FHS_R} and ${secondEndpointDN_RMOD_R}
            IF  '${item.firstEndpointDN}' == '${FHS_id}'
                Append To List  ${RMOD_list}  ${item.secondEndpointDN}
            END
        END
    END
    ${RMOD_list}=  Remove Duplicates  ${RMOD_list}
    RETURN  ${RMOD_list}

Check peer BTS states and alarms during Site Reset from ims
    [Arguments]  ${alias}  ${peer_aliases}  ${timestamp_start}  ${timestamp_end}

    IF  ${peer_aliases}
        Log Long String  /n***** Check the other BTS(s) status and alarms during "Reset Site" operation
        ...  on ${BTS_alias_label_dict}[${alias}] from ims *****  console=True
    END

    FOR  ${other_alias}  IN  @{peer_aliases}
        ${ims_file_path}=  Get Variable Value  ${${other_alias}_ims_file_path}  ${None}
        ${other_label}=  Get From Dictionary  ${BTS_alias_label_dict}  ${other_alias}
        ${IGNORED_ALARMS_FULL}=  Combine Lists  ${test_alarms_list['${other_alias.upper()}_IGNORED_ALARMS']}
        ...  ${test_alarms_list['IGNORED_ALARMS_DURING_RESET']}  ${test_alarms_list['IGNORED_ALARMS_DSS']}
        Set Test Variable  ${${other_alias}_IGNORED_ALARMS_FULL}  ${IGNORED_ALARMS_FULL}
        Check peer BTS status during reset BTS impact on connected FHSs  ${other_alias}  ${timestamp_start}  ${timestamp_end}  ${ims_file_path}
        Check peer BTS status during reset BTS impact on connected RMODs  ${other_alias}  ${timestamp_start}  ${timestamp_end}  ${ims_file_path}
        Check other BTS alarms from ims  ${other_alias}  ${timestamp_start}  ${ims_file_path}
    END

Check other BTS impacted equipment from ims
    [Arguments]  ${other_alias}  ${timestamp_start}  ${timestamp_end}  ${element_list}
    ...  ${element_list_description}  ${expected_state}  ${ims_file_path}  ${allow_no_updates}=${False}
    ...  ${enabled_check_or_disabled_check}=Enabled  ${kw_fail_if_check_nok}=${True}

    Log  \nCheck ${BTS_alias_label_dict}[${other_alias}] ${element_list_description}:  console=True

    ${overall_status}=  Set Variable  ${True}
    FOR  ${element_id}  IN  @{element_list}

        IF  '${enabled_check_or_disabled_check}'=='Enabled'
            ${enabled_check_param}=  Create Dictionary  ims_file_path=${ims_file_path}
            ...  obj_dist_name=${element_id}  obj_parameter_dict=${expected_state}
            ...  start_point_timestamp_UTC=${timestamp_start}  end_point_timestamp_UTC=${timestamp_end}
            ...  allow_no_updates=${allow_no_updates}  regex_parameter_value_search=${True}
            ${enabled_check}=  Set Variable  Check object parameters values are not changed from IMS file
            ${kw}=  Set Variable  ${enabled_check}
            ${args}=  Set Variable  ${enabled_check_param}
        ELSE
            ${expected_state_parameter}=  Get Dictionary Keys  ${expected_state}
            ${expected_state_split}=  Get Dictionary Values  ${expected_state}
            ${expected_state_value}=  Get Regexp Matches  ${expected_state_split[${0}]}  \\|([A-Za-z]+)\\"  1
            ${expected_state_value}=  Set Variable If  not ${expected_state_value}  ${expected_state_split[${0}]}  ${expected_state_value}

            ${disabled_check_param}=  Create Dictionary
            ...  ims_file_path=${ims_file_path}  object_dn=${element_id}  start_timestamp=${timestamp_start}
            ...  parameter_name=${expected_state_parameter}[${0}]  parameter_value=${expected_state_value}[${0}]
            ${disabled_check}=  Set Variable  Check object status change for desired parameter value
            ${kw}=  Set Variable  ${disabled_check}
            ${args}=  Set Variable  ${disabled_check_param}
        END
        ${status}=  Run Keyword And Return Status  ${kw}  &{args}
        ${overall_status}=  Set Variable If  not ${status}  ${status}  ${overall_status}

    END
    IF  ${overall_status}
        Log  ${BTS_alias_label_dict}[${other_alias}] ${element_list_description} - State as expected\n  console=True
    ELSE
        Log  ${BTS_alias_label_dict}[${other_alias}] ${element_list_description} - State NOT as expected!  level=WARN
    END
    IF  not ${overall_status} and ${kw_fail_if_check_nok}
        Run Keyword And Continue On Failure  Fail
        ...  ${BTS_alias_label_dict}[${other_alias}] ${element_list_description} - State NOT as expected! Check Failed!\n
    END

Check peer BTS status during reset BTS impact on connected FHSs
    [Arguments]  ${alias}  ${timestamp_start}  ${timestamp_end}  ${ims_file_path}

    IF  ${expected_${alias}_enabled_shared_FHS_id_list}
        Check other BTS impacted equipment from ims
        ...  ${alias}  ${timestamp_start}  ${timestamp_end}  ${expected_${alias}_enabled_shared_FHS_id_list}
        ...  shared FHSs expected Enabled (not losing sync during BTS Reset process)
        ...  ${FHS_state_enabled_dict}  ims_file_path=${ims_file_path}
        ...  enabled_check_or_disabled_check=Enabled
    END

    IF  ${expected_${alias}_disabled_shared_FHS_id_list}
        Check other BTS impacted equipment from ims
        ...  ${alias}  ${timestamp_start}  ${timestamp_end}  ${expected_${alias}_disabled_shared_FHS_id_list}
        ...  shared FHSs expected Disabled (losing sync during BTS Reset process)
        ...  ${FHS_state_disabled_dict}  ims_file_path=${ims_file_path}
        ...  enabled_check_or_disabled_check=Disabled
    END

Check peer BTS status during reset BTS impact on connected RMODs
    [Arguments]  ${alias}  ${timestamp_start}  ${timestamp_end}  ${ims_file_path}

    IF  ${expected_${alias}_enabled_shared_RMOD_id_list}
        Check other BTS impacted equipment from ims  ${alias}  ${timestamp_start}  ${timestamp_end}
        ...   ${expected_${alias}_enabled_shared_RMOD_id_list}
        ...  shared RMODs, expected Enabled (eCPRI+eCPRI_NETCONF+Obsai+CPRI which do not lose sync, CPRI w CB007447 feature which lose sync)
        ...  ${RMOD_state_enabled_dict}  ims_file_path=${ims_file_path}
        ...  enabled_check_or_disabled_check=Enabled
    END

    IF  ${expected_${alias}_disabled_shared_RMOD_id_list}
        Check other BTS impacted equipment from ims  ${alias}  ${timestamp_start}  ${timestamp_end}
        ...  ${expected_${alias}_disabled_shared_RMOD_id_list}
        ...  shared RMODs, expected Disabled (eCPRI+eCPRI_NETCONF+Obsai+CPRI which lose sync)
        ...  ${RMOD_state_disabled_dict}  ims_file_path=${ims_file_path}
        ...  enabled_check_or_disabled_check=Disabled
    END

    IF  ${expected_${alias}_enabled_dedicated_RMOD_id_list}
        Check other BTS impacted equipment from ims  ${alias}  ${timestamp_start}  ${timestamp_end}
        ...  ${expected_${alias}_enabled_dedicated_RMOD_id_list}
        ...  dedicated RMODs, expected Enabled (not connected in a resetting, shared FHS),
        ...  ${RMOD_state_enabled_dict}  ims_file_path=${ims_file_path}  allow_no_updates=${True}
        ...  enabled_check_or_disabled_check=Enabled
    END

    IF  ${expected_${alias}_disabled_dedicated_RMOD_id_list}
        Check other BTS impacted equipment from ims  ${alias}  ${timestamp_start}  ${timestamp_end}
        ...  ${expected_${alias}_disabled_dedicated_RMOD_id_list}
        ...  dedicated RMODs, expected Disabled (connected in a resetting, shared FHS),
        ...  ${RMOD_state_disabled_dict}  ims_file_path=${ims_file_path}  allow_no_updates=${True}
        ...  enabled_check_or_disabled_check=Disabled
    END

    IF  ${${alias}_enabled_cell_list} and ${${alias}_CB007447_status}
        Check other BTS impacted equipment from ims  ${alias}  ${timestamp_start}  ${timestamp_end}  ${${alias}_enabled_cell_list}
        ...  Cells, expected Enabled (mapped on Enabled RMODs)
        ...  ${CELL_state_enabled_dict}  ims_file_path=${ims_file_path}  allow_no_updates=${True}
        ...  enabled_check_or_disabled_check=Enabled
    END

    IF  ${${alias}_possibly_disabled_cell_list} and ${${alias}_CB007447_status}
        ${status}=    Run Keyword And Return Status
        ...  Check other BTS impacted equipment from ims  ${alias}
        ...  ${timestamp_start}  ${timestamp_end}  ${${alias}_possibly_disabled_cell_list}
        ...  Cells, expected Enabled (mapped on Enabled RMODs) but possibily impacted by X2 fail during Site Reset.
        ...  ${CELL_state_enabled_dict}  ims_file_path=${ims_file_path}  allow_no_updates=${True}
        ...  enabled_check_or_disabled_check=Enabled  kw_fail_if_check_nok=${False}
    ELSE
        ${status}=    Set Variable    ${True}
    END
    IF  not ${status}    Log  Check manually X2 status!  level=WARN


Check other BTS alarms from ims
    [Arguments]  ${other_alias}  ${timestamp}  ${ims_file_path}

    Log  \n***** Check ${BTS_alias_label_dict}[${other_alias}] alarms: *****\n  console=True
    Log Long String  From Obsai RMOD and FHS:
    ...  \n${BTS_alias_label_dict}[${other_alias}] "No connection to Unit (10)" alarm, expected number: ${${other_alias}_OBSAI_FHS_FID10_alarm_count}
    ...  console=True
    Log Long String  From CPRI RMOD w/o 7447:
    ...  \n${BTS_alias_label_dict}[${other_alias}] "No connection to Unit (10)" and
    ...  "Not able to synchronize baseband bus (1815)" alarm,
    ...  expected number (each): ${${other_alias}_CPRI_FID10_1815_alarm_count}  console=True
    Log Long String  From eCPRI+eCPRI_NETCONF RMOD which are not excepted from FID16 generation:
    ...  \n${BTS_alias_label_dict}[${other_alias}] "Unit synchronization failed (16)" alarm,
    ...  expected number: ${${other_alias}_ECPRI_FID16_alarm_count}\n  console=True

    Get And Check Detailed IMS2 Alarms SOAM  ims_file_path=${ims_file_path}  alias=${other_alias}  start_timestamp=${timestamp}
    ...  expected_alarms=${${other_alias}_EXPECTED_ALARMS_10_1815_16}
    ...  ignored_alarms=${${other_alias}_IGNORED_ALARMS_FULL}
    ...  critical_alarms=${test_alarms_list['${other_alias.upper()}_CRITICAL_ALARMS']}
    ...  only_unexpected_alarms_of_same_id_and_number_with_expected_alarms=${False}
    ...  skip_check_if_empty_expected_alarms=${False}

    Log Long String  \nFrom Obsai RMOD and FHS:\n${BTS_alias_label_dict}[${other_alias}]
    ...  "No connection to Unit (10)" alarm, found number:
    ...  ${${other_alias}_OBSAI_FHS_FID10_alarm_count}, as expected!  console=True
    Log Long String  From CPRI RMOD w/o 7447S:
    ...  \n${BTS_alias_label_dict}[${other_alias}] "No connection to Unit (10)" and
    ...  "Not able to synchronize baseband bus (1815)" alarm,
    ...  found number (each): ${${other_alias}_CPRI_FID10_1815_alarm_count}, as expected!  console=True
    Log Long String  From eCPRI+eCPRI_NETCONF RMOD which are not excepted from FID16 generation:
    ...  \n${BTS_alias_label_dict}[${other_alias}] "Unit synchronization failed (16)" alarm, found number:
    ...  ${${other_alias}_ECPRI_FID16_alarm_count}, as expected!  console=True
    Log  ${BTS_alias_label_dict}[${other_alias}] site - expected, ignored and critical alarms checked\n  console=True

Check other BTS states and alarms after Site Reset
    [Arguments]  ${alias}

    FOR  ${other_alias}  IN  @{alias_list}
        IF  '${other_alias}' == '${alias}'    CONTINUE
        ${other_label}=  Get From Dictionary  ${BTS_alias_label_dict}  ${other_alias}

        Log  Check ${other_label} status:  console=True
        ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_bts_reset}  ${BTS_MAX_WAIT_TIME}
        Admin Check BTS Procedural and Blocking states  ${OnAir_}  ${Unblocked_}  ${remained_MAX_WAIT_TIME}  ${other_alias}
        Log  ${other_label} site - proceduralState: OnAir, blockingState: Unblocked, as expected!  console=True
        ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_bts_reset}  ${BTS_MAX_WAIT_TIME}
        Admin Check all BTS cells expected states  ${CELL_state_enabled_check}  ${other_alias}  ${remained_MAX_WAIT_TIME}
        Log  All ${other_label} cell(s) status:\n - ${CELL_state_enabled}  console=True
        ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_bts_reset}  ${BTS_MAX_WAIT_TIME}
        Check cells availability status online  ${other_alias}  ${remained_MAX_WAIT_TIME}

        Log  Check ${other_label} alarms:  console=True
        Get and Check Alarms SOAM  alias=${other_alias}  expected_alarms=@{EMPTY}
        ...  ignored_alarms=${test_alarms_list['${other_alias.upper()}_IGNORED_ALARMS']}
        ...  critical_alarms=${test_alarms_list['${other_alias.upper()}_CRITICAL_ALARMS']}
        Log  ${other_label} site - expected, ignored and critical alarms checked  console=True
    END

Check peer BTS CPRI RMOD PM counters for CB007447
    [Arguments]  ${peer_aliases}

    FOR  ${peer_alias}  IN  @{peer_aliases}
        ${condition_skip_counter_check}=  Create Long String
        ...  not ${${peer_alias}_shared_CPRI_RMOD_supporting_CB007447_losing_sync_sn} or not ${PM_Counters_Check}
        ...  or not ${${peer_alias}_CB007447_status}
        IF  ${condition_skip_counter_check}    CONTINUE

        Log  Check ${BTS_alias_label_dict}[${peer_alias}] CPRI RMOD PM counters:  console=True
        FOR  ${RMOD_sn}  IN  @{${peer_alias}_shared_CPRI_RMOD_supporting_CB007447_losing_sync_sn}
            Check PM counters  M40015C10  ${RMOD_sn}  ${peer_alias}
        END
    END

Convert PM duration to seconds
    [Arguments]  ${pm_duration}

    ${pm_duration_value}=  Fetch From Left  ${pm_duration}  min
    ${pm_duration_value}=  Strip String  ${pm_duration_value}
    ${pm_duration_value_int}=  Convert To Integer  ${pm_duration_value}
    ${pm_duration_value_seconds}=  Evaluate  ${pm_duration_value_int}*60
    RETURN  ${pm_duration_value_seconds}

Check initial mt param
    [Arguments]  ${alias}  ${mt_param}

    ${scf_path}=  Admin Collect scf.xml with timestamp TAF  alias=${alias}
    ${dn_list}=  Get All Dist Names By Pattern from SCF  pattern=/PMMNL-[\\d]+$  scf_path=${scf_path}  alias=${alias}
    ${BTS_SCF_dn}=  Get From List  ${dn_list}  0
    ${mt_param_value}=  Check Parameter value from SCF  item_dist_name=${BTS_SCF_dn}
	...  parameter_to_check=${mt_param}  scf_path=${scf_path}
    Set Test variable  ${${alias}_${mt_param}_initial}  ${mt_param_value}
    IF  '${mt_param_value}' == '5min'
        Log  ${mt_param}_value already set to ${mt_param_value}. No action needed  console=True
        Set Test Variable  ${${alias}_${mt_param}}  ${mt_param_value}
    ELSE
        Log  Performing Parameter Recommissioning on BTS ${alias} parameter ${mt_param} to 5 min  console=True
        coam.Perform Parameter Recommissioning  dist_name=${BTS_SCF_dn}  parameter=${mt_param}  operation=update
        ...  value=5min  skip_parameter_relation_errors=False  should_activate=True  connection=${alias}
        Log  Waiting 5 min in for the PM period change to be taken into account  console=True
        Sleep  300s
        Set Test Variable  ${${alias}_${mt_param}}  5min
    END
    ${mt_param_seconds}=  Convert PM duration to seconds  ${${alias}_${mt_param}}
    Set Test Variable  ${${alias}_${mt_param}_seconds}  ${mt_param_seconds}
    Log  BTS ${alias} PM duration in seconds: ${${alias}_${mt_param}_seconds}  console=True

Check PM counters
    [Arguments]  ${counter_id}  ${RMOD_sn}  ${alias}

    Log  Checking ${counter_id} counter value on BTS ${alias}  console=True
    ${SMOD_params_list}=  Get From Dictionary  ${alias_SMOD_board_types_dict}  ${alias}
    ${RMOD_Id}=  Get From Dictionary  ${${alias}_module_SN_ID_dict}  ${RMOD_sn}
    ${LANE_Id}=  Get From Dictionary  ${${alias}_MODULE_LANE_dict}  ${RMOD_Id}
    ${LANE_Id}=  Set Variable  ${LANE_Id}[0]
    ${SFP_Id}=  Fetch From Left  ${LANE_Id}  /LANE_R-
    ${SFP_R_number}=  Fetch From Right  ${SFP_Id}  /SFP_R-
    ${module_R_id}=  Fetch From Left  ${SFP_Id}  /SFP_R-
    ${product Name}=  Set Variable   None

    FOR  ${SMOD_params}  IN  @{SMOD_params_list}
        ${SMOD_present}=  Run Keyword And Return Status  Dictionary Should Contain Key  ${SMOD_params}  ${module_R_id}
        IF  not ${SMOD_present}    CONTINUE
        ${product Name}=  Get From Dictionary  ${SMOD_params}  ${module_R_id}
        BREAK
    END

    ${is_ASOx}=  Run Keyword And Return Status  Should Match Regexp    ${product Name}}    ASO[\\s\\S] AirScale Core
    ${mt_param}=  Set Variable If  ${is_ASOx} and '${ASOx_counters_flag}'=='True'  mtSbtsSfpSmodLane  mtSbtsSfpBbmodLane
    ${alternate_counter_ids}=  Create Dictionary  M40015C10=M40014C10  M40015C11=M40014C11
    IF  ${is_ASOx} and '${ASOx_counters_flag}'=='True'
        Log Long String  Since ASOx_counters_flag=True and board product name is ${product Name},
        ...  counter ${alternate_counter_ids["${counter_id}"]} will apply!
        ...  console=True
    END
    ${counter_id_to_check}=  Set Variable If  ${is_ASOx} and '${ASOx_counters_flag}'=='True'
    ...  ${alternate_counter_ids["${counter_id}"]}  ${counter_id}
    ${LANE_R_number}=  Fetch From Right  ${LANE_Id}  /LANE_R-
    ${SFP_SCF_dn}=  Get SFP SCF distinguished name  ${SFP_Id}  ${alias}
    ${SFP_counters_path}=  Fetch From Left  ${SFP_SCF_dn}  /SFP-
    ${last_obj}=  Set Variable If  ${is_ASOx}  SBTS_SFP_SMOD_LANE  SBTS_SFP_BBMOD_LANE
    ${LANE_counters_dn}=  Set Variable  ${SFP_counters_path}/SFP-${SFP_R_number}/LANE-${LANE_R_number}/${last_obj}
    ${epoch_time_now}=  OperatingSystem.Run    date +%s
    ${elapsed_time_seconds}=    Evaluate  ${epoch_time_now}-${reset_site_event_epoch_time}
    ${remaining_time}=  Evaluate  ${${alias}_${mt_param}_seconds}-${elapsed_time_seconds}
    ${guard_time}=  Set Variable  45

    IF  ${remaining_time}>0
        Log  Waiting ${remaining_time}s for PM completion  console=True
        Sleep  ${remaining_time}s
    END
    Log  Waiting ${guard_time}s more as guard time to assure last PM availability  console=True
    Sleep  ${guard_time}s

    ${counter value}=  Get PM Counter Value from Admin
    ...  ${LANE_counters_dn}   ${counter_id_to_check}  ${reset_site_event_epoch_time}  ${${alias}_${mt_param}_seconds}  ${alias}
    Check counter value  ${counter_id_to_check}  ${counter value}  ${alias}

Check counter value
    [Arguments]    ${counter_id}  ${counter value}  ${alias}
    IF  ${counter value} == 0
        Log  ${counter_id} counter value: ${counter value}, not incremented! Please check logs  level=ERROR
        Mid Test Snapshot collection  ${alias}  PM counter ${counter_id} not incremented!
        Run Keyword And Continue On Failure  Fail  PM counter ${counter_id} on BTS ${alias} not incremented
        RETURN
    END
    IF  ${counter value} == 1
        Log  ${counter_id} counter value: ${counter value}, incremented as expected!  console=True
        RETURN
    END
    IF  ${counter value} == 2
        Log  ${counter_id} counter value: ${counter value}, incremented, but twice! Please check logs  level=WARN
        Mid Test Snapshot collection  ${alias}  PM counter ${counter_id} incremented twice!
        RETURN
    END
    IF  ${counter value} > 2
        Log  ${counter_id} counter value: ${counter value}, incremented more than twice! Please check logs  level=ERROR
        Mid Test Snapshot collection  ${alias}  PM counter ${counter_id} incremented more than twice
        Run Keyword And Continue On Failure  Fail  PM counter ${counter_id} on BTS ${alias} not incremented
        RETURN
    END

Mid Test Snapshot collection
    [Arguments]  ${alias}  ${reason}
    Log  Mid Test Snapshot collection for ${reason} problem found on BTS ${alias}  console=True
    ${timestamp}=  Get Current Date  result_format=%Y-%m-%d_%H:%M:%S
    ${path}=  Set Variable  ${Test Results Dir}/Snapshot
    Log  Snapshot file collection on BTS ${alias} started  console=True
    ${folder_path}  ${Snapshot_filename}=  Snapshot collection on demand SOAM  ${alias}  ${path}/${timestamp}_BTS_${alias}_${reason}
    Log  Snapshot file collected: ${folder_path}/${Snapshot_filename}  console=True
    Log  Wait static time of ${DELAY_BETWEEN_SNAPSHOTS} seconds between Snapshot collections  console=True
    Sleep  ${DELAY_BETWEEN_SNAPSHOTS}s

Hardware File Teardown
    IF    '${SWCONFIG_CHANGE_FLAG}' == 'False'    RETURN
    FOR  ${alias}  IN  @{BTS_alias_list}
        Recover HWF Flags  alias=${alias}
    END

Get epoch time after Reset Site
    ${event_epoch_time}=  GET event epoch time
    Set Test Variable  ${reset_site_event_epoch_time}  ${event_epoch_time}
    Log  Reset Site event epoch time: ${reset_site_event_epoch_time}  console=True

GET event epoch time
    ${epoch_time}=  OperatingSystem.Run    date +%s
    RETURN  ${epoch_time}

Recover initial settings for feature CB007447
    [Arguments]  ${alias}

    Log  ==============================================================  console=True
    Log  Recover initial settings for feature CB007447 on BTS ${alias}  console=True
    Log  ==============================================================  console=True

    Set feature CB007447 on BTS  alias=${alias}
    ...  cpriSyncBreakTime_value=${cpriSyncBreakTime}
    ...  stickToSyncSourcePeriod_value=${${alias}_stickToSyncSourcePeriod_initial}
    ...  actCpriLinkRecovery_value=${${alias}_actCpriLinkRecovery_initial}
    ...  actSyncLinkSwitchover_value=${${alias}_actSyncLinkSwitchover_initial}

    Set feature CB007447 on BTS  alias=${alias}
    ...  cpriSyncBreakTime_value=${${alias}_cpriSyncBreakTime_initial}
    ...  stickToSyncSourcePeriod_value=${${alias}_stickToSyncSourcePeriod_initial}
    ...  actCpriLinkRecovery_value=${${alias}_actCpriLinkRecovery_initial}
    ...  actSyncLinkSwitchover_value=${${alias}_actSyncLinkSwitchover_initial}

Recover initial mt param
    [Arguments]  ${alias}  ${mt_param}

    Log  ==============================================================  console=True
    Log  Recover initial settings for ${mt_param} on BTS ${alias}  console=True
    Log  ==============================================================  console=True

    ${scf_path}=  Admin Collect scf.xml with timestamp TAF  alias=${alias}
    ${dn_list}=  Get All Dist Names By Pattern from SCF  pattern=/PMMNL-[\\d]+$  scf_path=${scf_path}  alias=${alias}
    ${BTS_SCF_dn}=  Get From List  ${dn_list}  0
    ${mt_param_value}=  Check Parameter value from SCF  item_dist_name=${BTS_SCF_dn}
	...  parameter_to_check=${mt_param}  scf_path=${scf_path}
    IF  '${mt_param_value}' == '${${alias}_${mt_param}_initial}'
        Log  Parameter Recommissioning ${mt_param} not needed.  console=True
        RETURN
    END
    Log  Recovering initial value of ${mt_param} on BTS ${alias}: ${${alias}_${mt_param}_initial}  console=True
    coam.Perform Parameter Recommissioning  dist_name=${BTS_SCF_dn}  parameter=${mt_param}  operation=update
    ...  value=${${alias}_${mt_param}_initial}  skip_parameter_relation_errors=False  should_activate=True
    ...  connection=${alias}


Particular Teardown
    Export KPI results to File Global  kpi_log_file_name=KpiTimeInfo
    FOR  ${alias}  IN  @{alias_list}
        IF  ${PM_Counters_Check} and ${${alias}_CB007447_status} and not ${single_BTS}
            Recover initial settings for feature CB007447  ${alias}
            Recover initial mt param  ${alias}  mtSbtsSfpBbmodLane
            Recover initial mt param  ${alias}  mtSbtsSfpSmodLane
        END
    END

    Check all BTS cells availability status online
    Hardware File Teardown

TC Setup
    ${tech_preset_list}=  Create List  SBTS  SBTS  SBTS  SBTS
    Common Test Setup  preset_techs=${tech_preset_list}  common_sbts=${TRUE}
    ...  infomodelSetup=${FALSE}  newAlarmsFormat=${TRUE}

TC Teardown
    Common Test Teardown