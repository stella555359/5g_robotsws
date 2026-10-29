*** Settings ***
Documentation    TC__SBTS_SBTS__STATE__BTS_Power_Off_On
Variables    tc_variables/sbts_sbts__state__bts_power_off_on_alarms_definitions.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${REPEAT_COUNTER}              3     # Number of BTS power off/on operations, default value 3
${BTS_LIST}                    ALL   # BTS list on which power off/on operations will be performed.
                                     # Possible values (by default ALL):
                                     # - ALL: action will be performed on all BTS (power off/on on each BTS from TL)
                                     # - list of selected BTS separated by comma labeled as BTSx (x is test_pc number in init.py) (ex. BTS1, BTS2)
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
${BTS_POWER_ON_WRN_THR_LIST}   600   # Time (secs) spent between BTS power on and first cell up: in accordance with KPI3 specifications.
                                     # Possible values (by default 600 secs):
                                     # - single KPI value -> it will be used as KPI3 value for each BTS from ${BTS_LIST}
                                     # - list of KPI values separated by comma -> in this case, number of KPI values should be equal with number of
                                     # BTS on which power off/on operations will be performed (ex. 600, 800 means: 600 secs as KPI3 for first
                                     # BTS, 800 secs as KPI3 for second BTS)
${BTS_MAX_WAIT_TIME}           900   # Maximum time to wait for BTS OnAir after power on (by default 900)
${SWCONFIG_CHANGE_FLAG}  False  # Enable/disable HWF flags in swconfig.txt file. By default HWF flags change is disabled: False
${SWCONFIG_FLAG_ACTION}  add    # Action that should be done with the list of HWF flags in swconfig.txt. Possible values: add/remove
                                # - add: check requested HWF flags from swconfig.txt file and set if needed on 0 -> HWF will not be took into use
                                # - remove: check requested HWF flags from swconfig.txt file and remove if set on 0 -> HWF will be took into use
${SWCONFIG_FLAG_LIST}  0x4F0214  # List of HWF flags that will be added/removed in swconfig.txt. User provides the flags with spaces between them.
                                 # Possible values:
                                 # - 0x190030 (OAM_DBG_EnableHwfLoading) till SBTS00_ENB_9999_211214_000014 or on maintenance branches till SBTS22R1
                                 # - 0x4F0214 (ERadLteHas_BB_PERIPHERIES_EnableHwfLoading) from SBTS00_ENB_9999_211214_000014
                                 # For current SW trunk, flag 0x4F0214 should be used
*** Keywords ***
TC__SBTS_SBTS__STATE__BTS_Power_Off_On
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-28869
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  SBTS-SBTS test case for BTS power off/on operation, - x times sequence.
    ...  x - value of REPEAT_COUNTER parameter (default: 3)
    ...  The main steps performed for the test are:
    ...  - check initial state and alarms for both BTS
    ...  - get and set if needed shared RMOD primary link on requested BTS
    ...  - perform BTS power off checking (if peer BTS exists) peer BTS states and alarms during transitory and stable phase
    ...  - perform BTS power on checking both BTS states and alarms
    ...  - check reset behavior on both BTS based on IMS info as follows:
    ...    - BTS powered off/on: reset number is 1
    ...    - BTS not powered off/on: reset number is 0
    ...  - get and check KPI3 info from IMS file for BTS powered off/on
    ...  - check final state and alarms for both BTS
    ...  Pass criteria: BTS power off/on operation works as expected, states and alarms are as expected
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 10.03.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28869 - Generic test for SM Power off ON
    ...  - 07.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29457 -
    ...  Adapt SBTS_SBTS__STATE__BTS_Power_Off_On.robot to latest 7447 activation params
    ...  - 13.08.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29672 - Add option for HWF for NRL__STATE__NR_SM_Power_Off_On - 27.08
    ...  - 27.11.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30221 - Remove ${actForceUnitAutoReset}' in tests and KWs related to CB007447
    ...  - 03.03.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30579 - Check basic TA KWs RF 8 AXEGHA ORAN-ECPRI impact
    ...

    Set Tags    CA-STATE    OWNER-catalin.chiorean@nokia.com    AUTHOR-dinu.olariu@nokia.com    PHASE-QT    SW-SBTS25R2

    TC Preconditions
    Configure Hardware File
    Step 1: Check initial all BTS state
    Step 2: Check initial all BTS alarms
    Step 3: Check PDU definition and reachability
    Step 4: Get all BTS info
    FOR  ${INDEX}  IN RANGE  1  ${REPEAT_COUNTER}+1
        Log  ==============================================================================  console=True
        Log  Start Cycle ${INDEX} of ${REPEAT_COUNTER}  console=True
        Log  ==============================================================================  console=True
        Step 5: Perform BTS power off/on for iteration ${INDEX}
        Step 6: Check final all BTS state
        Step 7: Check final all BTS alarms
        Step 8: Check final number and state of Cells and RMs
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

    IF  '${BTS_LIST}' != 'ALL'    Check BTS list  ${BTS_label_alias_dict}  ${BTS_label_list}
    Log  =======================================================  console=True
    Log  BTS label list selected for BTS power off/on operation: ${BTS_label_list}  console=True
    Log  BTS alias list selected for BTS power off/on operation: ${BTS_alias_list}  console=True
    Log  =======================================================  console=True

    IF  '${BTS_PRIMARY_LINK_LIST}' != ''    Check BTS Primary Link list

    Check BTS KPI3 values

Configure Hardware File
    IF    '${SWCONFIG_CHANGE_FLAG}' == 'False'    RETURN
    FOR  ${alias}  IN  @{BTS_alias_list}
        Set HWF Flags  swconfig_flag_action=${SWCONFIG_FLAG_ACTION}  swconfig_flag_list=${SWCONFIG_FLAG_LIST}  alias=${alias}
    END

Step ${index}: Check ${when} all BTS state
    [Documentation]
    ...  SBTS state is checked according to Admin for BTS and each configured RAT

    Log  Step ${index}: Check ${when} all BTS state  console=True
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

    Log  Step ${index}: Check ${when} all BTS alarms  console=True
    FOR  ${alias}  IN  @{alias_list}
        Log  ***** Check ${when} BTS ${alias} alarms *****  console=True
        Get and Check Alarms SOAM  alias=${alias}  expected_alarms=@{EMPTY}  ignored_alarms=${test_alarms_list['${alias.upper()}_IGNORED_ALARMS']}
        ...  critical_alarms=${test_alarms_list['${alias.upper()}_CRITICAL_ALARMS']}
        Log  BTS ${alias} site - expected, ignored and critical alarms checked  console=True
    END

Step ${index}: Check PDU definition and reachability
    [Documentation]
    ...  Keyword used to check if BTS SMs PDU are defined, can be reached and their status is on

    Log  Step ${index}: Check PDU definition and reachability  console=True

    FOR  ${alias}  IN  @{BTS_alias_list}

        ${BTS_SM_PDU_if_name_list}=  Check BTS SMs PDU info definition  ${alias}
        Set Test Variable  ${${alias}_SM_PDU_if_name_list}  ${BTS_SM_PDU_if_name_list}

        ${status}=  Check BTS SMs PDU port status  ${${alias}_SM_PDU_if_name_list}  on
        IF  ${status}
            Log  BTS ${alias} SMs PDU port status as expected  console=True
        ELSE
            Log  PDU for BTS ${alias} SMs is either not reachable or not switched on!  level=ERROR
            Fail  PDU for BTS ${alias} SMs is either not reachable or not switched on!
        END

    END

Step ${index}: Get all BTS info
    [Documentation]
    ...  Keyword used to all BTS info related to sync, RMOD, can be reached and their status is on

    Log  Step ${index}: Get all BTS info  console=True

    ${all_BTS_controller_role_RMOD_sn_dict}=  Get all BTS controller role for configured RMOD from SCF
    Set Test Variable  ${all_BTS_controller_role_RMOD_sn_dict}

    ${all_BTS_controller_role_FHS_sn_dict}=  Get all BTS controller role for configured FHS from SCF
    Set Test Variable  ${all_BTS_controller_role_FHS_sn_dict}

    Get all BTS SMOD BBMOD list
    Get all BTS Synchronization info
    Get all BTS RAT cell list
    Get all BTS RMOD sn id pn interface info
    Check CB007447 feature settings
    Check CB010846 feature settings

    ${BTS_XP_localAlias_remoteAlias_dict}  ${NRBTS_DSS_alias_actLteNrDss_dict}  ${LNBTS_DSS_alias_actLteNrDss_dict}
    ...  ${BTS_DSS_NR_LTE_CELL_scf_dict}  ${BTS_DSS_LTE_NR_CELL_scf_dict}  ${BTS_DSS_NR_LTE_CELL_dict}  ${BTS_DSS_LTE_NR_CELL_dict}=
    ...  Get all BTS DSS feature info
    Set Test Variable  ${BTS_XP_localAlias_remoteAlias_dict}
    Set Test Variable  ${NRBTS_DSS_alias_actLteNrDss_dict}
    Set Test Variable  ${LNBTS_DSS_alias_actLteNrDss_dict}
    Set Test Variable  ${BTS_DSS_NR_LTE_CELL_dict}
    Set Test Variable  ${BTS_DSS_LTE_NR_CELL_dict}

    ${NR_DSS_alarms_info}=  Create Long String  "EN DSS De-activated on partner side (7513)" or "EN DSS Keep Alive Procedure Time out (7511)" or
    ...  "EN DSS Setup Failure - Max EN DSS Counter Value reached - No answer from CRM (7509)" alarm alarm
    ${LTE_DSS_alarms_info}=  Create Long String  "EN DSS De-activated on partner side (6134)" or "EN DSS Keep Alive Procedure Time out (6132)" or
    ...  "EN DSS Setup Failure - Max EN DSS Counter Value reached - No DSS Partner Cell (6129)" alarm

    Set Test Variable  ${NR_DSS_alarms_info}
    Set Test Variable  ${LTE_DSS_alarms_info}

    Set Test Variable  ${RMOD_state_enabled_check}  operationalState=${Enabled_}, administrativeState=${Unlocked_}
    Set Test Variable  ${RMOD_state_enabled}  operationalState=Enabled, administrativeState=Unlocked
    Set Test Variable  ${RMOD_state_enabled_degraded_check}
    ...  operationalState=${Enabled_}, availabilityStatus=${Degraded_}, administrativeState=${Unlocked_}
    Set Test Variable  ${RMOD_state_enabled_degraded}  operationalState=Enabled, availabilityStatus=Degraded, administrativeState=Unlocked
    Set Test Variable  ${CELL_state_enabled_check}  operationalState=${Enabled_}, blockingState=${Unblocked_}
    Set Test Variable  ${CELL_state_enabled}  operationalState=Enabled, blockingState=Unblocked
    Set Test Variable  ${CELL_state_disabled_check}
    ...  operationalState=${Disabled_}, availabilityStatus=${Failed_Offline_}, blockingState=${Unblocked_}
    Set Test Variable  ${CELL_state_disabled}  operationalState=Disabled, availabilityStatus=Failed|Offline, blockingState=Unblocked

Step ${index}: Perform BTS power off/on for iteration ${CYCLE}
    [Documentation]
    ...  Perform BTS power off/on

    Log  Step ${index}: Perform BTS power off/on for iteration ${CYCLE}  console=True

    Set Test Variable  ${CYCLE}

    FOR  ${alias}  IN  @{BTS_alias_list}

        Set shared fronthaul modules Primary Link before BTS power off/on  ${alias}

        Get shared fronthaul modules Primary Link before BTS power off/on  ${alias}

        Perform BTS power off  ${alias}  ${peer_aliases}

        Perform BTS power on  ${alias}  ${peer_aliases}

        Check all BTS reset behavior based on IMS info  ${alias}  ${peer_aliases}

        Get and check KPI3 info from IMS file  ${alias}

    END

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]
    ...  Following checks are performed:
    ...  - number of configured cells and radio modules in SCF are properly mapped on BTS running view ADMIN
    ...  - check cells states
    ...  - check radio modules states

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

        IF  '${item}' not in ${BTS_label_list}
            Append To List  ${BTS_invalid_label_list}  ${item}
        ELSE
            Append To List  ${BTS_request_label_list}  ${item}
        END

    END

    IF  '${BTS_check}' == 'False'
        Log Long String  Following selected BTS are not valid: ${BTS_invalid_label_list}.
        ...   Please select values for test argument \${BTS_LIST} from
        ...   configured BTS: ${BTS_label_list} or let default value: ALL  console=True
        Fail  Improper value for argument!
    END

    FOR  ${item}  IN  @{BTS_request_label_list}

        ${BTS_request_alias}=  Get From Dictionary  ${BTS_label_alias_dict}  ${item}
        Append To List  ${BTS_request_alias_list}  ${BTS_request_alias}

    END

    Set Test Variable  ${BTS_label_list}  ${BTS_request_label_list}
    Set Test Variable  ${BTS_alias_list}  ${BTS_request_alias_list}

Check BTS Primary Link list
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
        Log Long String  Following selected BTS are not valid: ${BTS_PL_invalid_label_list}. Please select values for test argument
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

Check BTS KPI3 values
    ${BTS_POWER_ON_WRN_THR_LIST_strip}=  Replace String  ${BTS_POWER_ON_WRN_THR_LIST}  ${SPACE}  ${EMPTY}
    ${BTS_KPI_LIST}=  Split String  ${BTS_POWER_ON_WRN_THR_LIST_strip}  ,
    ${BTS_KPI_LIST_length}=  Get Length  ${BTS_KPI_LIST}

    IF  ${BTS_KPI_LIST_length} == 1
        Create BTS KPI info dict  ${BTS_alias_list}  ${BTS_KPI_LIST}
        RETURN
    END

    ${BTS_LIST_length}=  Get Length  ${BTS_alias_list}

    IF  ${BTS_KPI_LIST_length} != ${BTS_LIST_length}
        Log Long String  Number of KPI values set for test argument \${BTS_POWER_ON_WRN_THR_LIST}
        ...  is not aligned with number of selected BTS for
        ...  power off/on operations. Please align values for \${BTS_POWER_ON_WRN_THR_LIST}
        ...  according to \${BTS_LIST} info or let default value!  level=ERROR
        Fail  Improper value for argument!
    END

    Create BTS KPI info dict  ${BTS_alias_list}  ${BTS_KPI_LIST}

Create BTS KPI info dict
    [Arguments]  ${BTS_alias_list}  ${BTS_KPI_LIST}

    ${BTS_alias_BTS_KPI_dict}=  Create Dictionary
    ${BTS_KPI_LIST_length}=  Get Length  ${BTS_KPI_LIST}

    FOR  ${index}  ${alias}  IN ENUMERATE  @{BTS_alias_list}

        IF  ${BTS_KPI_LIST_length} == 1
            ${BTS_KPI}=    Get From List  ${BTS_KPI_LIST}  0
        ELSE
            ${BTS_KPI}=    Get From List  ${BTS_KPI_LIST}  ${index}
        END

        Set To Dictionary  ${BTS_alias_BTS_KPI_dict}  ${alias}  ${BTS_KPI}

    END

    Set Test Variable  ${BTS_alias_BTS_KPI_dict}

Get all BTS Synchronization info
    [Documentation]
    ...  Helper Keyword used to get synchronization info on BTS

    FOR  ${alias}  IN  @{alias_list}

        ${syncMode}  ${syncInputType}  ${tuningMode}  ${syncHubRole}  ${syncMaster}  ${holdOverModeUsed}=
        ...  Admin Get BTS Synchronization Information
        ...  ${alias}
        Log  BTS ${alias} synchronization hub role: ${syncHubRole}  console=True
        Set Test Variable  ${${alias}_syncHubRole}  ${syncHubRole}

    END

Get all BTS SMOD BBMOD list

    FOR  ${alias}  IN  @{alias_list}

       ${SMOD_id_list}=  Get Ids For All  class_name=SMOD  connection=${alias}
       ${BBMOD_id_list}=  Get Ids For All  class_name=BBMOD  connection=${alias}
       ${BTS_MOD_id_list}=  Combine Lists  ${SMOD_id_list}  ${BBMOD_id_list}
       Set Test Variable  ${${alias}_MOD_id_list}  ${BTS_MOD_id_list}

    END

Get all BTS RAT cell list

    FOR  ${alias}  IN  @{alias_list}

       Get BTS CELL list by RAT  ${alias}

    END

Get BTS CELL list by RAT
    [Arguments]  ${alias}

    ${NR_cell_id_list}=  Get Ids For All  class_name=NRCEL  connection=${alias}
    ${LTE_cell_id_list}=  Get Ids For All  class_name=LNCEL  connection=${alias}
    ${WCDMA_cell_id_list}=  Get Ids For All  class_name=WNCEL  connection=${alias}
    ${GSM_cell_id_list}=  Get Ids For All  class_name=GNCEL  connection=${alias}
    ${BTS_cell_id_list}=  Combine Lists   ${NR_cell_id_list}  ${LTE_cell_id_list}  ${WCDMA_cell_id_list}  ${GSM_cell_id_list}

    Set Test Variable  ${${alias}_NR_cell_id_list}  ${NR_cell_id_list}
    Set Test Variable  ${${alias}_LTE_cell_id_list}  ${LTE_cell_id_list}
    Set Test Variable  ${${alias}_WCDMA_cell_id_list}  ${WCDMA_cell_id_list}
    Set Test Variable  ${${alias}_GSM_cell_id_list}  ${GSM_cell_id_list}
    Set Test Variable  ${${alias}_BTS_cell_id_list}  ${BTS_cell_id_list}

Get all BTS RMOD sn id pn interface info

    FOR  ${alias}  IN  @{alias_list}

       ${BTS_RMOD_sn_id_dict}  ${BTS_RMOD_id_sn_dict}  ${BTS_RMOD_sn_pn_dict}  ${BTS_RMOD_sn_interface_dict}=
       ...  Admin Get RMOD sn id pn interface info
       ...  ${alias}
       Set Test Variable  ${${alias}_RMOD_sn_id_dict}  ${BTS_RMOD_sn_id_dict}

    END

Check CB007447 feature settings

    FOR  ${alias}  IN  @{alias_list}

        ${actCpriLinkRecovery}  ${actSyncLinkSwitchover}  ${cpriSyncBreakTime}  ${stickToSyncSourcePeriod}=
        ...  Get feature CB007447 info  ${alias}

        IF  '${actCpriLinkRecovery}' == 'true' and '${actSyncLinkSwitchover}' == 'true'
            Log  BTS ${alias} CB007447 feature status: Enabled  console=True
            Set Test Variable  ${${alias}_CB007447_status}  ${TRUE}
        ELSE
            Log  BTS ${alias} CB007447 feature status: Disabled  console=True
            Set Test Variable  ${${alias}_CB007447_status}  ${FALSE}
        END

    END

Check CB010846 feature settings

    FOR  ${alias}  IN  @{alias_list}

        ${BTS_CB010846_feature_dict}=  Get BTS CB010846 feature parameters
        ...  BTS_SCF_path_file=${${alias.lower()}_scf_initial}  alias=${alias}

        ${actRuResetResiliency}=  Get From Dictionary  ${BTS_CB010846_feature_dict}  actRuResetResiliency
        ${uncntrldResetMplaneBreakTime}=  Get From Dictionary  ${BTS_CB010846_feature_dict}  uncntrldResetMplaneBreakTime

        IF  '${actRuResetResiliency}' == 'true'
            Log  BTS ${alias} CB010846 feature status: Enabled, uncntrldResetMplaneBreakTime=${uncntrldResetMplaneBreakTime}
            ...  console=True
            Set Test Variable  ${${alias}_CB010846_status}  ${TRUE}
            Set Test Variable  ${${alias}_uncntrldResetMplaneBreakTime}  ${uncntrldResetMplaneBreakTime}
        ELSE
            Log  BTS ${alias} CB010846 feature status: Disabled  console=True
            Set Test Variable  ${${alias}_CB010846_status}  ${FALSE}
        END

    END

Set shared fronthaul modules Primary Link before BTS power off/on
    [Arguments]  ${alias}

    [Documentation]
    ...  Set shared fronthaul modules (FHS, RMOD) Primary Link if needed

    ${BTS_MOD_id_list_dict}=  Create Dictionary  Equipment_enabled=${${alias}_MOD_id_list}
    ${BTS_MOD_equipment_dict}  ${BTS_MOD_detailed_equipment_dict}=
    ...  Get BTS equipment connected by Cablink
    ...  ${BTS_MOD_id_list_dict}
    ...  ${alias}
    ...  Max_equipment_level=${1}
    ...  Reset_dependency_rules=${Reset_dependency_rules}

    Log  Set shared fronthaul modules Primary Link before BTS ${alias} power off/on   console=True

    IF  '${BTS_PRIMARY_LINK_LIST}' == ''
        Log  - test action will be performed with existing shared fronthaul modules Primary Link configuration  console=True
        RETURN
    END

    ${BTS_PL_label}=  Get From Dictionary  ${BTS_alias_BTS_PL_label_dict}  ${alias}
    ${BTS_PL_alias}=  Get From Dictionary  ${BTS_label_alias_dict}  ${BTS_PL_label}

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

Get shared fronthaul modules Primary Link before BTS power off/on
    [Arguments]  ${alias}

    ${dependency_rules_dict_name}=  Set Variable If  ${${alias}_CB007447_status}
    ...  Reset_dependency_rules_CB007447  Reset_dependency_rules
    ${dependency_rules_dict}=  Get Variable Value  ${${dependency_rules_dict_name}}

    ${BTS_MOD_id_dict}=  Create Dictionary  Equipment_reset=${${alias}_MOD_id_list}
    ${TL_detailed_equipment_dict}=  Get Testline equipment connected by Cablink
    ...  Source_equipment_id_dict=${BTS_MOD_id_dict}
    ...  alias=${alias}
    ...  alias_list=${alias_list}
    ...  Reset_dependency_rules=${dependency_rules_dict}

    ${aliases}=  Get Dictionary Keys  ${TL_detailed_equipment_dict}
    ${peer_aliases}=  Copy List  ${aliases}
    Remove Values From List  ${peer_aliases}  ${alias}

    Set Test Variable  ${peer_aliases}

    Prepare peer BTS transitory alarm list for check  ${peer_aliases}  ${TL_detailed_equipment_dict}

Perform BTS power off
    [Arguments]  ${alias}  ${peer_aliases}

    Count peer BTS expected alarms related to TFM feature info  ${peer_aliases}
    Count peer BTS expected alarms related to TRM feature info  ${peer_aliases}

    Log  ***** Perform BTS ${alias} power off *****  console=True

    Get Current Date UTC info  power_off
    Log  BTS ${alias} power off UTC timestamp: ${date_timestamp_power_off_UTC}  console=True

    ${status}=  Set BTS SMs PDU port status  ${${alias}_SM_PDU_if_name_list}  off
    IF  ${status}
        Log  BTS ${alias} SMs PDU port status off, as expected  console=True
    ELSE
        Log  Set BTS ${alias} SMs PDU port status off failed!  level=ERROR
        Fail  Set BTS ${alias} SMs PDU port status off failed!
    END
    Get Current Time  initial

    Check peer BTS alarms in transitory phase  ${peer_aliases}

    Get Current Time  final

    Wait for reach stable phase  ${peer_aliases}

    Count peer BTS expected alarms related to DSS feature info  ${alias}  ${peer_aliases}
    Prepare peer BTS stable alarm list for check  ${peer_aliases}
    Check peer BTS alarms in stable phase  ${peer_aliases}
    Check peer BTS RMODs state in stable phase  ${peer_aliases}
    Check peer BTS cells state in stable phase  ${peer_aliases}

Perform BTS power on
    [Arguments]  ${alias}  ${peer_aliases}

    ${hostname_ip}=  Set Variable  ${${alias.upper()}}[${alias.upper()}_TECH_IP_ADDRESS]
    ${remote_host_ip}=  Set Variable If  '${alias}' == 'Master'  None  ${${alias.upper()}}[${alias.upper()}_PC_IP_ADDRESS]

    Log  ***** Perform BTS ${alias} power on *****  console=True
    Get Current Date UTC info  power_on
    Log  BTS ${alias} power on UTC timestamp: ${date_timestamp_power_on_UTC}  console=True

    ${status}=  Set BTS SMs PDU port status  ${${alias}_SM_PDU_if_name_list}  on
    IF  ${status}
        Log  BTS ${alias} SMs PDU port status on, as expected  console=True
    ELSE
        Log  Set BTS ${alias} SMs PDU port status on failed!  level=ERROR
        Fail  Set BTS ${alias} SMs PDU port status on failed!
    END

    IF  not ${peer_aliases}
        Wait For Target To Be Reachable TAF  hostname=${${alias_local.upper()}}[${alias_local.upper()}_TECH_IP_ADDRESS]  timeout=180
        Sleep  120 sec
    END

    Check fault 4001 on BTS  ${peer_aliases}

    Log  Check BTS ${alias} cells after BTS ${alias} powered on:  console=True
    Check cells availability status online  ${alias}  ${BTS_MAX_WAIT_TIME}
    Log  BTS ${alias} all cells status:\n - operationalState=Enabled  console=True

    Log  Check BTS ${alias} alarms after BTS ${alias} powered on:  console=True
    Get and Check Alarms SOAM  alias=${alias}  wait_for_alarm_clear= 15min  expected_alarms=@{EMPTY}
    ...  ignored_alarms=${test_alarms_list['${alias.upper()}_IGNORED_ALARMS']}
    ...  critical_alarms=${test_alarms_list['${alias.upper()}_CRITICAL_ALARMS']}
    Log  BTS ${alias} site - expected, ignored and critical alarms checked  console=True

    FOR  ${peer_alias}  IN  @{peer_aliases}

        Log  Check BTS ${peer_alias} cells after BTS ${alias} powered on:  console=True
        Check cells availability status online  ${alias}  ${BTS_MAX_WAIT_TIME}
        Log  BTS ${peer_alias} all cells status:\n - operationalState=Enabled  console=True

        Log  Check BTS ${peer_alias} alarms after BTS ${alias} powered on:  console=True
        Get and Check Alarms SOAM  alias=${peer_alias}  wait_for_alarm_clear=15 min  expected_alarms=@{EMPTY}
        ...  ignored_alarms=${test_alarms_list['${peer_alias.upper()}_IGNORED_ALARMS']}
        ...  critical_alarms=${test_alarms_list['${peer_alias.upper()}_CRITICAL_ALARMS']}
        Log  BTS ${peer_alias} site - expected, ignored and critical alarms checked  console=True

    END

Prepare peer BTS transitory alarm list for check
    [Arguments]  ${peer_aliases}  ${TL_detailed_equipment_dict}

    FOR  ${alias}  IN  @{peer_aliases}

        ${detailed_dependent_peer_equipment_dict}=  Get From Dictionary  ${TL_detailed_equipment_dict}  ${alias}

        ${BTS_EXPECTED_ALARMS_OBSAI_RMOD_count}  ${BTS_EXPECTED_ALARMS_CPRI_RMOD_count}  ${BTS_EXPECTED_ALARMS_ECPRI_RMOD_count}=
        ...  Get peer BTS alarms  ${detailed_dependent_peer_equipment_dict}  ${alias}
        ${BTS_EXPECTED_ALARMS_10_1815_count}=  Evaluate  ${BTS_EXPECTED_ALARMS_OBSAI_RMOD_count} + ${BTS_EXPECTED_ALARMS_CPRI_RMOD_count}

        Set Test Variable  ${${alias.upper()}_EXPECTED_ALARMS_10_1815_count}  ${BTS_EXPECTED_ALARMS_10_1815_count}
        Set Test Variable  ${${alias.upper()}_EXPECTED_ALARMS_16_count}  ${BTS_EXPECTED_ALARMS_ECPRI_RMOD_count}

        ${BTS_EXPECTED_ALARMS_OBSAI_RMOD_list}=  Prepare expected alarms list
        ...  ${test_alarms_list['${alias.upper()}_EXPECTED_ALARMS_10']}
        ...  ${BTS_EXPECTED_ALARMS_OBSAI_RMOD_count}
        ${BTS_EXPECTED_ALARMS_CPRI_RMOD_list}=  Prepare expected alarms list
        ...  ${test_alarms_list['${alias.upper()}_EXPECTED_ALARMS_10_1815']}
        ...  ${BTS_EXPECTED_ALARMS_CPRI_RMOD_count}
        ${BTS_EXPECTED_ALARMS_ECPRI_RMOD_list}=  Prepare expected alarms list
        ...  ${test_alarms_list['${alias.upper()}_EXPECTED_ALARMS_16']}
        ...  ${BTS_EXPECTED_ALARMS_ECPRI_RMOD_count}

        ${BTS_EXPECTED_ALARMS_transitory_list}=  Combine Lists
        ...  ${BTS_EXPECTED_ALARMS_OBSAI_RMOD_list}
        ...  ${BTS_EXPECTED_ALARMS_CPRI_RMOD_list}
        ...  ${BTS_EXPECTED_ALARMS_ECPRI_RMOD_list}
        ${BTS_IGNORED_ALARMS_transitory_list}=  Combine Lists
        ...  ${test_alarms_list['${alias.upper()}_IGNORED_ALARMS']}
        ...  ${test_alarms_list['${alias.upper()}_IGNORED_ALARMS_TRANSITORY_BTS_POWERED_OFF']}

        Set Test Variable  ${${alias.upper()}_EXPECTED_ALARMS_transitory_list}  ${BTS_EXPECTED_ALARMS_transitory_list}
        Set Test Variable  ${${alias.upper()}_IGNORED_ALARMS_transitory_list}  ${BTS_IGNORED_ALARMS_transitory_list}

    END

Get peer BTS alarms
    [Arguments]  ${detailed_dependent_peer_equipment_dict}  ${alias}

    ${RMOD_OBSAI_list}=  Get Combined List From Dictionary  ${detailed_dependent_peer_equipment_dict}
    ...  SHARED_RMOD_OBSAI_disabled  DEDICATED_RMOD_OBSAI_disabled
    ${RMOD_FHS_CPRI_list}=  Get Combined List From Dictionary  ${detailed_dependent_peer_equipment_dict}
    ...  SHARED_RMOD_CPRI_disabled  DEDICATED_RMOD_CPRI_disabled
    ...  SHARED_FHS_CPRI_disabled
    ${RMOD_ECPRI_list}=  Get Combined List From Dictionary  ${detailed_dependent_peer_equipment_dict}
    ...  SHARED_RMOD_ECPRI_disabled  DEDICATED_RMOD_ECPRI_disabled
    ...  SHARED_RMOD_ECPRI_NETCONF_disabled  DEDICATED_RMOD_ECPRI_NETCONF_disabled

    ${OBSAI_FID10_alarm_count}=  Get Length  ${RMOD_OBSAI_list}
    ${CPRI_FID10_1815_alarm_count}=  Get Length  ${RMOD_FHS_CPRI_list}
    ${ECPRI_FID16_alarm_count}=  Get Length  ${RMOD_ECPRI_list}

    FOR  ${item}  IN  @{RMOD_ECPRI_list}
        ${RMOD_param}=  Get Parameters For  class_name=RMOD  id_num=${item}  connection=${alias}
        IF  not('${RMOD_param['productName']}' in ${RMOD_ECPRI_fid16_exceptions})
            CONTINUE
        END
        ${ECPRI_FID16_alarm_count}=  Evaluate  ${ECPRI_FID16_alarm_count} - ${1}
    END

    RETURN  ${OBSAI_FID10_alarm_count}  ${CPRI_FID10_1815_alarm_count}  ${ECPRI_FID16_alarm_count}

Count peer BTS expected alarms related to TFM feature info
    [Arguments]  ${peer_aliases}

    FOR  ${alias}  IN  @{peer_aliases}

        ${BTS_controller_FHS_sn_dict}=
        ...  Get From Dictionary  ${all_BTS_controller_role_FHS_sn_dict}  ${alias}
        ${BTS_secondary_controller_FHS_sn_list}=
        ...  Get From Dictionary  ${BTS_controller_FHS_sn_dict}  BTS_secondary_controller_FHS_sn_list
        ${BTS_secondary_controller_FHS_sn_count}=  Get Length  ${BTS_secondary_controller_FHS_sn_list}
        Set Test Variable  ${${alias}_secondary_controller_FHS_sn_count}  ${BTS_secondary_controller_FHS_sn_count}

        IF    ${BTS_secondary_controller_FHS_sn_count} == 0    RETURN

        ${BTS_TFM_feature_dict}=  Get BTS TFM feature parameters  BTS_SCF_path_file=${${alias.lower()}_scf_initial}  alias=${alias}
        ${actTempFhsPrimController}=
        ...  Get From Dictionary  ${BTS_TFM_feature_dict}  actTempFhsPrimController
        ${tempFhsPrimControllerTriggerTime}=
        ...  Get From Dictionary  ${BTS_TFM_feature_dict}  tempFhsPrimControllerTriggerTime
        Set Test Variable  ${${alias}_actTempFhsPrimController}  ${actTempFhsPrimController}
        Set Test Variable  ${${alias}_tempFhsPrimControllerTriggerTime}  ${tempFhsPrimControllerTriggerTime}

    END

Count peer BTS expected alarms related to TRM feature info
    [Arguments]  ${peer_aliases}

    FOR  ${alias}  IN  @{peer_aliases}

        ${BTS_controller_RMOD_sn_list}=  Get From Dictionary  ${all_BTS_controller_role_RMOD_sn_dict}  ${alias}
        ${BTS_secondary_controller_RMOD_sn_list}=
        ...  Get From Dictionary  ${BTS_controller_RMOD_sn_list}  BTS_secondary_controller_RMOD_sn_list
        ${BTS_secondary_controller_RMOD_sn_count}=
        ...  Get Length  ${BTS_secondary_controller_RMOD_sn_list}
        Set Test Variable  ${${alias}_secondary_controller_RMOD_sn_count}  ${BTS_secondary_controller_RMOD_sn_count}

        IF    ${BTS_secondary_controller_RMOD_sn_count} == 0    RETURN

        ${BTS_TRM_feature_dict}=  Get BTS TRM feature parameters  BTS_SCF_path_file=${${alias.lower()}_scf_initial}  alias=${alias}
        ${actTempRadioMaster}=
        ...  Get From Dictionary  ${BTS_TRM_feature_dict}  actTempRadioMaster
        ${tempRadioMasterTriggerTime}=
        ...  Get From Dictionary  ${BTS_TRM_feature_dict}  tempRadioMasterTriggerTime
        ${tempRadioMasterRecovTime}=
        ...  Get From Dictionary  ${BTS_TRM_feature_dict}  tempRadioMasterRecovTime
        Set Test Variable  ${${alias}_actTempRadioMaster}  ${actTempRadioMaster}
        Set Test Variable  ${${alias}_tempRadioMasterTriggerTime}  ${tempRadioMasterTriggerTime}
        Set Test Variable  ${${alias}_tempRadioMasterRecovTime}  ${tempRadioMasterRecovTime}

    END

Count peer BTS expected alarms related to DSS feature info
    [Arguments]  ${alias}  ${peer_aliases}

    ${BTS_alias_NR_DSS_alarms_dict}=  Create Dictionary
    ${BTS_alias_LTE_DSS_alarms_dict}=  Create Dictionary

    FOR  ${peer_alias}  IN  @{peer_aliases}

        ${LTE_DSS_alarms_count}=  Set Variable  0
        ${NR_DSS_alarms_count}=  Set Variable  0

        FOR  ${cell_id}  IN  @{${alias}_NR_cell_id_list}

            ${DSS_peer_cell_id}  ${DSS_peer_rat}  ${DSS_peer_alias}=  Get DSS feature impact  ${cell_id}  NR  ${alias}

            ${cond}=  Set Variable  '${DSS_peer_cell_id}' != 'None' and '${DSS_peer_alias}' not in ['${alias}', 'None']
            IF  not ${cond}    CONTINUE

            ${DSS_peer_cell_status}=  Run Keyword And Return Status
            ...  Assert
            ...  class_name=LNCEL  id=${DSS_peer_cell_id}  parameters=operationalState=${Enabled_}
            ...  timeout=3  connection=${DSS_peer_alias}

            IF  '${DSS_peer_cell_status}' == 'True'
                ${LTE_DSS_alarms_count}=    Evaluate  ${LTE_DSS_alarms_count} + 1
            ELSE
                ${LTE_DSS_alarms_count}=    Set Variable  ${LTE_DSS_alarms_count}
            END

            IF  '${DSS_peer_cell_status}' == 'True'
                Set To Dictionary  ${BTS_alias_LTE_DSS_alarms_dict}  ${DSS_peer_alias}=${LTE_DSS_alarms_count}
            END

        END

        FOR  ${cell_id}  IN  @{${alias}_LTE_cell_id_list}

            ${DSS_peer_cell_id}  ${DSS_peer_rat}  ${DSS_peer_alias}=  Get DSS feature impact  ${cell_id}  LTE  ${alias}

            ${cond}=  Set Variable  '${DSS_peer_cell_id}' != 'None' and '${DSS_peer_alias}' not in ['${alias}', 'None']
            IF  not ${cond}    CONTINUE

            ${DSS_peer_cell_status}=  Run Keyword And Return Status
            ...  Assert
            ...  class_name=NRCEL  id=${DSS_peer_cell_id}
            ...  parameters=operationalState=${Enabled_}
            ...  timeout=3  connection=${DSS_peer_alias}

            IF  '${DSS_peer_cell_status}' == 'True'
                ${NR_DSS_alarms_count}=    Evaluate  ${NR_DSS_alarms_count} + 1
            ELSE
                ${NR_DSS_alarms_count}=    Set Variable  ${NR_DSS_alarms_count}
            END

            IF  '${DSS_peer_cell_status}' == 'True'
                Set To Dictionary  ${BTS_alias_NR_DSS_alarms_dict}  ${DSS_peer_alias}=${NR_DSS_alarms_count}
            END

        END

        FOR  ${cell_id}  IN  @{${peer_alias}_NR_cell_id_list}

            ${cell_status}=  Run Keyword And Return Status
            ...  Assert  class_name=NRCEL  id=${cell_id}  parameters=operationalState=${Enabled_}  timeout=3  connection=${peer_alias}
            IF  '${cell_status}' == 'True'    CONTINUE

            ${DSS_peer_cell_id}  ${DSS_peer_rat}  ${DSS_peer_alias}=  Get DSS feature impact  ${cell_id}  NR  ${peer_alias}

            ${cond}=  Set Variable  '${DSS_peer_cell_id}' != 'None' and '${DSS_peer_alias}' == '${peer_alias}'
            IF  not ${cond}    CONTINUE

            ${DSS_peer_cell_status}=  Run Keyword And Return Status
            ...  Assert
            ...  class_name=LNCEL  id=${DSS_peer_cell_id}
            ...  parameters=operationalState=${Enabled_}
            ...  timeout=3  connection=${DSS_peer_alias}

            IF  '${DSS_peer_cell_status}' == 'True'
                ${LTE_DSS_alarms_count}=    Evaluate  ${LTE_DSS_alarms_count} + 1
            ELSE
                ${LTE_DSS_alarms_count}=    Set Variable  ${LTE_DSS_alarms_count}
            END

            IF  '${DSS_peer_cell_status}' == 'True'
                Set To Dictionary  ${BTS_alias_LTE_DSS_alarms_dict}  ${DSS_peer_alias}=${LTE_DSS_alarms_count}
            END

        END

        FOR  ${cell_id}  IN  @{${peer_alias}_LTE_cell_id_list}

            ${cell_status}=  Run Keyword And Return Status
            ...  Assert
            ...  class_name=LNCEL  id=${cell_id}  parameters=operationalState=${Enabled_}
            ...  timeout=3  connection=${peer_alias}
            IF  '${cell_status}' == 'True'    CONTINUE

            ${DSS_peer_cell_id}  ${DSS_peer_rat}  ${DSS_peer_alias}=  Get DSS feature impact  ${cell_id}  LTE  ${peer_alias}

            ${cond}=  Set Variable  '${DSS_peer_cell_id}' != 'None' and '${DSS_peer_alias}' == '${peer_alias}'
            IF  not ${cond}    CONTINUE

            ${DSS_peer_cell_status}=  Run Keyword And Return Status
            ...  Assert
            ...  class_name=NRCEL  id=${DSS_peer_cell_id}  parameters=operationalState=${Enabled_}
            ...  timeout=3  connection=${DSS_peer_alias}

            IF  '${DSS_peer_cell_status}' == 'True'
                ${NR_DSS_alarms_count}=    Evaluate  ${NR_DSS_alarms_count} + 1
            ELSE
                ${NR_DSS_alarms_count}=    Set Variable  ${NR_DSS_alarms_count}
            END

            IF  '${DSS_peer_cell_status}' == 'True'
                Set To Dictionary  ${BTS_alias_NR_DSS_alarms_dict}  ${DSS_peer_alias}=${NR_DSS_alarms_count}
            END

        END

    END
    Set Test Variable  ${BTS_alias_NR_DSS_alarms_dict}
    Set Test Variable  ${BTS_alias_LTE_DSS_alarms_dict}

Get DSS feature impact
    [Arguments]  ${cell_id}  ${rat}  ${alias}

    ${DSS_peer_rat}=  Set Variable If  '${rat}' == 'NR'  LTE  NR

    IF  '${rat}' == 'NR'
        ${actLteNrDss}=    Get From Dictionary  ${NRBTS_DSS_alias_actLteNrDss_dict}  ${alias}
    ELSE IF  '${rat}' == 'LTE'
        ${actLteNrDss}=    Get From Dictionary  ${LNBTS_DSS_alias_actLteNrDss_dict}  ${alias}
    END

    IF    '${actLteNrDss}' == 'False'    RETURN    ${None}    ${DSS_peer_rat}    ${None}

    ${DSS_NR_LTE_CELL_dict}=  Get From Dictionary  ${BTS_DSS_NR_LTE_CELL_dict}  ${alias}
    ${DSS_LTE_NR_CELL_dict}=  Get From Dictionary  ${BTS_DSS_LTE_NR_CELL_dict}  ${alias}
    ${DSS_NR_LTE_dict_keys}=  Get Dictionary Keys  ${DSS_NR_LTE_CELL_dict}
    ${DSS_LTE_NR_dict_keys}=  Get Dictionary Keys  ${DSS_LTE_NR_CELL_dict}

    IF  '${rat}' == 'NR' and '${cell_id}' in ${DSS_NR_LTE_dict_keys}
        ${DSS_peer_cell_id}=    Get From Dictionary  ${DSS_NR_LTE_CELL_dict}  ${cell_id}
    ELSE IF  '${rat}' == 'LTE' and '${cell_id}' in ${DSS_LTE_NR_dict_keys}
        ${DSS_peer_cell_id}=    Get From Dictionary  ${DSS_LTE_NR_CELL_dict}  ${cell_id}
    ELSE
        ${DSS_peer_cell_id}=    Set Variable  None
    END

    IF    '${DSS_peer_cell_id}' == 'None'    RETURN    ${None}    ${DSS_peer_rat}    ${None}

    ${DSS_peer_alias_list}=  Get From Dictionary  ${BTS_XP_localAlias_remoteAlias_dict}  ${alias}
    ${DSS_peer_alias}=  Get DSS peer BTS  ${DSS_peer_cell_id}  ${DSS_peer_rat}  ${DSS_peer_alias_list}

    RETURN  ${DSS_peer_cell_id}  ${DSS_peer_rat}  ${DSS_peer_alias}

Get DSS peer BTS
    [Arguments]  ${DSS_peer_cell_id}  ${DSS_peer_rat}  ${DSS_peer_alias_list}

    ${DSS_peer_alias}=  Set Variable  None

    FOR  ${alias}  IN  @{DSS_peer_alias_list}

        ${DSS_peer_alias}=  Set Variable If  '${DSS_peer_cell_id}' in ${${alias}_${DSS_peer_rat}_cell_id_list}  ${alias}
        IF  '${DSS_peer_alias}' != 'None'    BREAK

    END

    RETURN  ${DSS_peer_alias}

Prepare peer BTS stable alarm list for check
    [Arguments]  ${peer_aliases}

    FOR  ${alias}  IN  @{peer_aliases}

        IF  '${${alias}_syncHubRole}' == 'Slave'
            ${BTS_EXPECTED_ALARMS_SYNC}=    Set Variable  ${test_alarms_list['${alias.upper()}_EXPECTED_ALARMS_1898_4385']}
        ELSE
            ${BTS_EXPECTED_ALARMS_SYNC}=    Create List
        END

        ${NR_DSS_alarms}=  Run Keyword And Return Status  Dictionary Should Contain Key  ${BTS_alias_NR_DSS_alarms_dict}  ${alias}
        ${LTE_DSS_alarms}=  Run Keyword And Return Status  Dictionary Should Contain Key  ${BTS_alias_LTE_DSS_alarms_dict}  ${alias}
        IF  ${NR_DSS_alarms}
            ${NR_DSS_alarms_count}=    Get From Dictionary  ${BTS_alias_NR_DSS_alarms_dict}  ${alias}
        ELSE
            ${NR_DSS_alarms_count}=    Set Variable  0
        END
        IF  ${LTE_DSS_alarms}
            ${LTE_DSS_alarms_count}=    Get From Dictionary  ${BTS_alias_LTE_DSS_alarms_dict}  ${alias}
        ELSE
            ${LTE_DSS_alarms_count}=    Set Variable  0
        END
        ${NR_DSS_EXPECTED_ALARMS_full}=  Prepare expected alarms list
        ...  ${test_alarms_list['${alias.upper()}_ALARMS_NR_DSS']}  ${NR_DSS_alarms_count}
        ${LTE_DSS_EXPECTED_ALARMS_full}=  Prepare expected alarms list
        ...  ${test_alarms_list['${alias.upper()}_ALARMS_LTE_DSS']}  ${LTE_DSS_alarms_count}

        ${BTS_EXPECTED_ALARMS_TRM}=  Prepare expected alarms list  ${test_alarms_list['${alias.upper()}_EXPECTED_ALARMS_4220']}
        ...  ${${alias}_secondary_controller_RMOD_sn_count}

        ${BTS_EXPECTED_ALARMS_stable_list}=  Combine Lists
        ...  ${BTS_EXPECTED_ALARMS_SYNC}  ${NR_DSS_EXPECTED_ALARMS_full}  ${LTE_DSS_EXPECTED_ALARMS_full}
        ...  ${BTS_EXPECTED_ALARMS_TRM}

        ${BTS_IGNORED_ALARMS_stable_list}=  Combine Lists  ${test_alarms_list['${alias.upper()}_IGNORED_ALARMS']}
        ...  ${test_alarms_list['${alias.upper()}_IGNORED_ALARMS_STABLE_BTS_POWERED_OFF']}

        Set Test Variable  ${${alias.upper()}_NR_DSS_alarms_count}  ${NR_DSS_alarms_count}
        Set Test Variable  ${${alias.upper()}_LTE_DSS_alarms_count}  ${LTE_DSS_alarms_count}
        Set Test Variable  ${${alias.upper()}_EXPECTED_ALARMS_stable_list}  ${BTS_EXPECTED_ALARMS_stable_list}
        Set Test Variable  ${${alias.upper()}_IGNORED_ALARMS_stable_list}  ${BTS_IGNORED_ALARMS_stable_list}

    END

Check peer BTS alarms in transitory phase
    [Arguments]  ${peer_aliases}

    FOR  ${alias}  IN  @{peer_aliases}

        Log  Check peer BTS ${alias} alarms in transitory phase:  console=True

        IF  ${${alias.upper()}_EXPECTED_ALARMS_10_1815_count} > 0
            Log Long String  BTS ${alias} "No connection to Unit (10)" or
            ...  "Not able to synchronize baseband bus (1815)" alarm, expected number:
            ...  ${${alias.upper()}_EXPECTED_ALARMS_10_1815_count}  console=True
        END
        IF  ${${alias.upper()}_EXPECTED_ALARMS_16_count} > 0
            Log Long String  BTS ${alias} "Unit synchronization failed (16)" alarm, expected number:
            ...  ${${alias.upper()}_EXPECTED_ALARMS_16_count}
            ...  console=True
        END

        Get and Check Alarms SOAM  alias=${alias}  poll_interval=5s
        ...  expected_alarms=${${alias.upper()}_EXPECTED_ALARMS_transitory_list}
        ...  ignored_alarms=${${alias.upper()}_IGNORED_ALARMS_transitory_list}
        ...  critical_alarms=${test_alarms_list['${alias.upper()}_CRITICAL_ALARMS']}

        IF  ${${alias.upper()}_EXPECTED_ALARMS_10_1815_count} > 0
            Log Long String  BTS ${alias} "No connection to Unit (10)" or
            ...  "Not able to synchronize baseband bus (1815)" alarm, found number:
            ...  ${${alias.upper()}_EXPECTED_ALARMS_10_1815_count}  console=True
        END
        IF  ${${alias.upper()}_EXPECTED_ALARMS_16_count} > 0
            Log Long String  BTS ${alias} "Unit synchronization failed (16)" alarm, found number:
            ...  ${${alias.upper()}_EXPECTED_ALARMS_16_count}
            ...  console=True
        END

        Log  BTS ${alias} site - expected, ignored and critical alarms checked  console=True

    END

Check peer BTS alarms in stable phase
    [Arguments]  ${peer_aliases}

    FOR  ${alias}  IN  @{peer_aliases}

        Log  Check peer BTS ${alias} alarms in stable phase:  console=True

        IF  '${${alias}_syncHubRole}' == 'Slave'
            Log  BTS ${alias} "PPS reference missing (1898) or PPS reference from backplane missing (4385)" alarm, expected number: 1
            ...  console=True
        END
        IF  ${${alias.upper()}_NR_DSS_alarms_count} > 0
            Log  BTS ${alias} ${NR_DSS_alarms_info}, expected number: ${${alias.upper()}_NR_DSS_alarms_count}  console=True
        END
        IF  ${${alias.upper()}_LTE_DSS_alarms_count} > 0
            Log  BTS ${alias} ${LTE_DSS_alarms_info}, expected number: ${${alias.upper()}_LTE_DSS_alarms_count}  console=True
        END
        IF  ${${alias}_secondary_controller_RMOD_sn_count} > 0
            Log Long String  BTS ${alias} "Radio slave has taken temporary radio master role (4220)" alarm, expected number:
            ...  ${${alias}_secondary_controller_RMOD_sn_count}  console=True
        END

        Get and Check Alarms SOAM  alias=${alias}  expected_alarms=${${alias.upper()}_EXPECTED_ALARMS_stable_list}
        ...  ignored_alarms=${${alias.upper()}_IGNORED_ALARMS_stable_list}
        ...  critical_alarms=${test_alarms_list['${alias.upper()}_CRITICAL_ALARMS']}

        IF  '${${alias}_syncHubRole}' == 'Slave'
            Log  BTS ${alias} "PPS reference missing (1898) or PPS reference from backplane missing (4385)" alarm, found number: 1
            ...  console=True
        END
        IF  ${${alias.upper()}_NR_DSS_alarms_count} > 0
            Log  BTS ${alias} ${NR_DSS_alarms_info}, found number: ${${alias.upper()}_NR_DSS_alarms_count}, as expected!
            ...  console=True
        END
        IF  ${${alias.upper()}_LTE_DSS_alarms_count} > 0
            Log  BTS ${alias} ${LTE_DSS_alarms_info}, found number: ${${alias.upper()}_LTE_DSS_alarms_count}, as expected!
            ...  console=True
        END
        IF  ${${alias}_secondary_controller_RMOD_sn_count} > 0
            Log Long String  BTS ${alias} "Radio slave has taken temporary radio master role (4220)" alarm, found number:
            ...  ${${alias}_secondary_controller_RMOD_sn_count}, as expected!  console=True
        END

        Log  BTS ${alias} site - expected, ignored and critical alarms checked  console=True

    END

Check peer BTS RMODs state in stable phase
    [Arguments]  ${peer_aliases}

    FOR  ${alias}  IN  @{peer_aliases}

        ${BTS_controller_RMOD_sn_list}=  Get From Dictionary  ${all_BTS_controller_role_RMOD_sn_dict}  ${alias}
        ${BTS_primary_controller_RMOD_sn_list}=
        ...  Get From Dictionary  ${BTS_controller_RMOD_sn_list}  BTS_primary_controller_RMOD_sn_list
        ${BTS_secondary_controller_RMOD_sn_list}=
        ...  Get From Dictionary  ${BTS_controller_RMOD_sn_list}  BTS_secondary_controller_RMOD_sn_list

        IF  ${BTS_primary_controller_RMOD_sn_list}
            Log  Check peer BTS ${alias} (as primary controller) RMOD status in stable phase:  console=True
            Check BTS RMODs state  RMOD_sn_list=${BTS_primary_controller_RMOD_sn_list}
            ...  RMOD_state_check=${RMOD_state_enabled_check}
            ...  RMOD_state=${RMOD_state_enabled}  timeout=60  alias=${alias}
        END

        IF  ${BTS_secondary_controller_RMOD_sn_list}
            Log  Check peer BTS ${alias} (as secondary controller) RMOD status in stable phase:  console=True
            Check BTS RMODs state  RMOD_sn_list=${BTS_secondary_controller_RMOD_sn_list}
            ...  RMOD_state_check=${RMOD_state_enabled_degraded_check}
            ...  RMOD_state=${RMOD_state_enabled_degraded}  timeout=60  alias=${alias}
        END

    END

Check peer BTS cells state in stable phase
    [Arguments]  ${peer_aliases}

    FOR  ${alias}  IN  @{peer_aliases}

        IF  ${${alias}_NR_cell_id_list}
            Log  Check peer BTS ${alias} NR cells status in stable phase:  console=True
            Wait Until Keyword Succeeds  900 sec  10 sec  Check NR cells state and MIMO alarm
            ...  cell_list=${${alias}_NR_cell_id_list}
            ...  alias=${alias}
        END

        IF  ${${alias}_LTE_cell_id_list}
            Log  Check peer BTS ${alias} LTE cells status in stable phase:  console=True
            Wait Until Keyword Succeeds  60 sec  10 sec  Check LTE cells state and MIMO alarm
            ...  cell_list=${${alias}_LTE_cell_id_list}
            ...  alias=${alias}
        END

        IF  ${${alias}_WCDMA_cell_id_list}
            Log  Check peer BTS ${alias} WCDMA cells status in stable phase:  console=True
            Wait Until Keyword Succeeds  60 sec  10 sec  Check WCDMA cells state and MIMO alarm
            ...  cell_list=${${alias}_WCDMA_cell_id_list}
            ...  alias=${alias}
        END

        IF  ${${alias}_GSM_cell_id_list}
            Log  Check peer BTS ${alias} GSM cells status in stable phase:  console=True
            Wait Until Keyword Succeeds  60 sec  10 sec  Check GSM cells state and MIMO alarm
            ...  cell_list=${${alias}_GSM_cell_id_list}
            ...  alias=${alias}
        END

    END

Wait for reach stable phase
    [Arguments]  ${peer_aliases}

    FOR  ${alias}  IN  @{peer_aliases}

        Log  Wait for check peer BTS ${alias} behavior in stable phase  console=True

        ${elapsed_time}=  DateTime.Subtract Date from Date  ${time_final}  ${time_initial}  number
        ${wait_time}=  Evaluate  300 - ${elapsed_time}
        ${ALARMS_10_1815_16_count}=  Evaluate
        ...  ${${alias.upper()}_EXPECTED_ALARMS_10_1815_count} + ${${alias.upper()}_EXPECTED_ALARMS_16_count}

        IF  ${${alias}_CB010846_status} and ${ALARMS_10_1815_16_count} > 0
            Sleep  ${${alias}_uncntrldResetMplaneBreakTime} sec
        END

        IF  ${${alias}_secondary_controller_RMOD_sn_count} == 0
            Sleep  ${wait_time} sec
            RETURN
        END

        IF  '${${alias}_actTempRadioMaster}' == 'true' and '${${alias}_tempRadioMasterTriggerTime}' != 'None'
            Sleep  ${${alias}_tempRadioMasterTriggerTime} min
        END

    END

Check BTS RMODs state
    [Arguments]  ${RMOD_sn_list}  ${RMOD_state_check}  ${RMOD_state}  ${timeout}  ${alias}

    FOR  ${RMOD_sn}  IN  @{RMOD_sn_list}

        ${RMOD_id}=  Get From Dictionary  ${${alias}_RMOD_sn_id_dict}  ${RMOD_sn}
        Assert  class_name=RMOD  id=${RMOD_id}  parameters=${RMOD_state_check}
        ...  timeout=${timeout}  connection=${alias}
        Log  BTS ${alias} RMOD_${RMOD_sn} status:\n - ${RMOD_state}  console=True

    END

Check fault 4001 on BTS
    [Arguments]  ${peer_aliases}

    FOR  ${alias}  IN  @{peer_aliases}

        ${hostname_ip}=  Set Variable  ${${alias.upper()}}[${alias.upper()}_TECH_IP_ADDRESS]
        ${remote_host_ip}=  Set Variable If  '${alias}' == 'Master'
        ...  None  ${${alias.upper()}}[${alias.upper()}_PC_IP_ADDRESS]

        ${FID4001_active}=  Run Keyword And Return Status  Assert Alarm Active
        ...  parameters=faultId=4001  timeout=600  connection=${alias}
        IF    '${FID4001_active}' == 'False'    RETURN

        ${FID4001_autonomous_reset}=  Run Keyword And Return Status  Assert Alarm Active
        ...  parameters=faultId=4001, alarmId=7101  connection=${alias}
        IF  ${FID4001_autonomous_reset}
            Log  BTS ${alias} site autonomous reset as recovery action  console=True
            Wait For Target To Be Not Reachable TAF  hostname=${hostname_ip}  remote_host=${remote_host_ip}  timeout=300
            Wait For Target To Be Reachable TAF  hostname=${hostname_ip}  remote_host=${remote_host_ip}  timeout=300
            Set Test Variable  ${${alias}_FID4001_reset}  ${TRUE}
            Sleep  60s  Wait for Admin starting
            Admin Check all BTS cells expected states  expected_state=${CELL_state_enabled_check}  alias=${alias}
            RETURN
        END

        Log  BTS ${alias} reset is needed to activate features requiring network level synchronization accuracy
        ...  console=True
        coam.Reset Site  connection=${alias}
        Set Test Variable  ${${alias}_FID4001_reset}  ${TRUE}
        Sleep  60s  Wait for Admin starting
        Admin Check all BTS cells expected states  expected_state=${CELL_state_enabled_check}  alias=${alias}

    END

Check all BTS reset behavior based on IMS info
    [Documentation]
    ...  BTS RESET info is checked based on IMS info. Reset behavior as expected if:
    ...  - BTS powered off/on: reset number is 1
    ...  - BTS not powered off/on: reset number is 0 or 1 (depending FID4001)
    ...  Otherwise, reset behavior not as expected, then errors are added to report and failed.
    [Arguments]  ${alias}  ${peer_aliases}

    Log  Check all BTS reset behavior based on IMS info  console=True
    Get Current Date UTC info  end

    Get and check BTS RESET info from IMS file  expected_reset_number=1  alias=${alias}
    ...  start_point_timestamp_UTC=${date_timestamp_power_off_UTC}  end_point_timestamp_UTC=${date_timestamp_end_UTC}

    FOR  ${peer_alias}  IN  @{peer_aliases}

        ${BTS_FID4001_reset}=  Get Variable Value  ${${peer_alias}_FID4001_reset}  ${FALSE}
        ${peer_BTS_expected_reset_number}=  Set Variable If  ${BTS_FID4001_reset}  1  0

        Get and check BTS RESET info from IMS file  expected_reset_number=${peer_BTS_expected_reset_number}  alias=${peer_alias}
        ...  start_point_timestamp_UTC=${date_timestamp_power_off_UTC}  end_point_timestamp_UTC=${date_timestamp_end_UTC}

    END

Get and check KPI3 info from IMS file
    [Documentation]
    ...  Get and check KPI3 info from IMS file.
    [Arguments]  ${alias}

    Log  Get and check KPI3 info from IMS file  console=True
    ${BTS_KPI}=  Get From Dictionary  ${BTS_alias_BTS_KPI_dict}  ${alias}
    ${kpi_name_delta_dict}=  Get and check KPI info from IMS file  kpi_names=kpi3  kpi_thresholds=${BTS_KPI}  alias=${alias}
    ...  start_point_timestamp_UTC=${date_timestamp_power_on_UTC}  end_point_timestamp_UTC=${date_timestamp_end_UTC}
    ${kpi_delta_list}=  Get From Dictionary  ${kpi_name_delta_dict}  kpi3

    Export KPI Results to File  alias=${alias}  obj=BTS  obj_type=SBTS  obj_id=BTS ${alias}  action_1=BTS_Power_On  kpi_reported_1=KPI_3
    ...  event_value_1=${kpi_delta_list[0]}  cycle=${CYCLE}  source_info=ims

Hardware File Teardown
    IF    '${SWCONFIG_CHANGE_FLAG}' == 'False'    RETURN
    FOR  ${alias}  IN  @{BTS_alias_list}
        Recover HWF Flags  alias=${alias}
    END

Particular Teardown
    FOR  ${alias}  IN  @{BTS_alias_list}
        Run Keyword And Continue On Failure  Recover BTS SMs PDU port status  ${${alias}_SM_PDU_if_name_list}  on  ${alias}
    END
    Export KPI results to File Global  kpi_log_file_name=KpiTimeInfo
    Check all BTS cells availability status online
    Hardware File Teardown

TC Setup
    ${tech_preset_list}=  Create List  SBTS  SBTS
    Common Test Setup  preset_techs=${tech_preset_list}  common_sbts=${TRUE}  infomodelSetup=${FALSE}  newAlarmsFormat=${TRUE}

TC Teardown
    Common Test Teardown
