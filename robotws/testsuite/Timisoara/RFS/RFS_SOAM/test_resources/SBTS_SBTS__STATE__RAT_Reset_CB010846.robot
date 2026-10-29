*** Settings ***
Documentation    TC__SBTS_SBTS__STATE__RAT_Reset_CB010846
Variables    tc_variables/sbts_sbts__state__rat_reset_cb010846_alarms_definitions.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${REPEAT_COUNTER}              3     # Number of Hard RAT Reset operations, default value 3
${cntrldResetMplaneBreakTime}  420   # Maximum time when Radio Unit tries to re-establish released M-plane connection to BTS after baseband HW reset.
                                     # Should be in range: 220 - 600 (seconds), by default 420
${RAT_LIST}                    ALL   # RAT list on which Hard RAT Reset operation will be performed. Possible values (by default ALL):
                                     # - ALL: action will be performed on all RATs configured on all BTS
                                     # - list of selected RATs separated by comma, possible values: NR, LTE, WCDMA, GSM (ex. NR, LTE)
${NR_RESET_WRN_THR}            120   # Time from first cell down to last cell up defined in seconds for NR RAT. Defaults to 120.
${LTE_RESET_WRN_THR}           120   # Time from first cell down to last cell up defined in seconds for LTE RAT.
                                     # Defaults to 120. For ABIO/ABIN should modified to 270 seconds
${WCDMA_RESET_WRN_THR}         120   # Time from first cell down to last cell up defined in seconds for WCDMA RAT.
                                     # Defaults to 120 based on NCF_SRAN_MR6
${GSM_RESET_WRN_THR}           120   # Time from first cell down to last cell up defined in seconds for GSM RAT. Defaults to 120.
${RAT_MAX_WAIT_TIME}           900   # Maximum time for wait of RAT OnAir
${GRACEFUL_CELL_SHUTDOWN}      True  # Graceful cell shutdown: True or False; default value: True

*** Keywords ***
TC__SBTS_SBTS__STATE__RAT_Reset_CB010846
     [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-28300
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  SBTS-SBTS test case for Hard RAT Reset on BTS, - x times sequence.
    ...  x - value of REPEAT_COUNTER parameter (default: 3)
    ...  The main steps performed for the test are:
    ...  - check initial state and alarms for all BTS
    ...  - get all BTS info
    ...  - perform Hard RAT Reset operation on requested RAT from each BTS checking states and alarms on all BTS
    ...  - check reset behavior on all BTS as follows: no reset
    ...  - check final state and alarms for both BTS
    ...  Pass criteria: Hard Reset RAT operation works as expected, states and alarms are as expected
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 20.11.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28300 -
    ...  [CB010846] Improvement - New Testcases : BB Capacity board improvement in reconfiguration and recovery - RAT Reset - EST48.5
    ...  - 19.12.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28550 - [5G] Exclude RMOD's supplementary check during RAT reset
    ...  - 16.01.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28504 - [CB010846] RAT Reset without RU Reset- 7447 CPRI peer check
    ...  - 17.11.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30185 - Adapt SBTS_SBTS__STATE__Uncontrolled_L1Soc_Reset_CB010846 with
    ...  ${actForceUnitAutoReset}' == 'false' case when CB007447 is enabled
    ...  - 27.11.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30221 - Remove ${actForceUnitAutoReset}' in tests and KWs related to CB007447

    Set Tags    CA-STATE    OWNER-florina.stefan@nokia.com    AUTHOR-dinu.olariu@nokia.com    PHASE-QT

    TC Preconditions
    Step 1: Check initial all BTS state
    Step 2: Check initial all BTS alarms
    Step 3: Check CB010846 feature settings
    Step 4: Get all BTS info for configured items
    FOR  ${INDEX}  IN RANGE  1  ${REPEAT_COUNTER}+1
        Log  ==============================================================================  console=True
        Log  Start Cycle ${INDEX} of ${REPEAT_COUNTER}  console=True
        Log  ==============================================================================  console=True
        Step 5: Perform RAT Reset operation on all BTS for iteration ${INDEX}
        Step 6: Check final all BTS state
        Step 7: Check final all BTS alarms
        Step 8: Check final number and state of Cells and RMs
    END

    [Teardown]  Particular Teardown

TC Preconditions
    Check RAT list

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

        Get and Check Alarms SOAM  alias=${alias}  expected_alarms=@{EMPTY}  ignored_alarms=${test_alarms_list['${alias.upper()}_IGNORED_ALARMS']}
        ...  critical_alarms=${test_alarms_list['${alias.upper()}_CRITICAL_ALARMS']}

        Log  BTS ${alias} site - expected, ignored and critical alarms checked  console=True

    END

Step ${index}: Check CB010846 feature settings
    [Documentation]
    ...  Check CB010846 feature settings on BTS

    Log  Step ${index}: Check CB010846 feature settings  console=True

    FOR  ${alias}  IN  @{alias_list}

        Log  Check CB010846 feature settings on BTS ${alias} and set them accordingly if needed  console=True

        ${BTS_CB010846_feature_dict}=  Get BTS CB010846 feature parameters  BTS_SCF_path_file=${${alias.lower()}_scf_initial}  alias=${alias}

        Set Test Variable  ${${alias}_BTS_CB010846_feature_dict}  ${BTS_CB010846_feature_dict}

        Set classical BTS CB010846 feature parameter  actRuResetResiliency  true  ${alias}
        Set classical BTS CB010846 feature parameter  cntrldResetMplaneBreakTime  ${cntrldResetMplaneBreakTime}  ${alias}

    END

    Log  Step ${index}: Get CB007447 feature status  console=True

    FOR  ${alias}  IN  @{alias_list}

        Log  Get CB007447 feature status on BTS ${alias}  console=True

        ${actCpriLinkRecovery}  ${actSyncLinkSwitchover}  ${cpriSyncBreakTime}  ${stickToSyncSourcePeriod}=  Get feature CB007447 info  ${alias}

        ${condition}=  Create Long String  '${actCpriLinkRecovery}' == 'true' and '${actSyncLinkSwitchover}' == 'true'

        Run Keyword If  ${condition}  Run Keywords
        ...  Log  BTS ${alias} CB007447 feature status: Enabled  console=True
        ...  AND  Set Test Variable  ${${alias}_CB007447_status}  ${TRUE}
        ...  ELSE  Run Keywords
        ...  Log  BTS ${alias} CB007447 feature status: Disabled  console=True
        ...  AND  Set Test Variable  ${${alias}_CB007447_status}  ${FALSE}

    END

Step ${index}: Get all BTS info for configured items
    [Documentation]
    ...  Get all BTS info about following items:
    ...  - list of dedicated and shared RMOD serial number on BTS
    ...  - list of dedicated and shared RMOD serial number eligible for CB010846 on BTS

    Log  Step ${index}: Get all BTS info for configured items  console=True

    Get all BTS Modules SN ID mapping

    ${BTS_alias_RMOD_sn_dict}  ${RMOD_sn_BTS_alias_dict}  ${shared_RMOD_sn_list}  ${dedicated_RMOD_sn_list}=  Get all BTS RMOD sharing info
    Set Test Variable  ${BTS_alias_RMOD_sn_dict}
    Set Test Variable  ${RMOD_sn_BTS_alias_dict}

    ${BTS_alias_RMOD_sn_RMOD_buildVersion_dict}  ${BTS_alias_RMOD_sn_RMOD_l3Protocol_dict}=  Get all BTS RMOD buildVersion and l3Protocol info

    ${BTS_alias_shared_RMOD_sn_dict}=  Get all BTS shared RMOD info  ${BTS_alias_RMOD_sn_dict}  ${shared_RMOD_sn_list}
    Set Test Variable  ${BTS_alias_shared_RMOD_sn_dict}

    ${BTS_alias_dedicated_RMOD_sn_dict}=  Get all BTS dedicated RMOD info  ${BTS_alias_RMOD_sn_dict}  ${dedicated_RMOD_sn_list}
    Set Test Variable  ${BTS_alias_dedicated_RMOD_sn_dict}

    ${BTS_alias_CB010846_shared_RMOD_sn_dict}=  Get all BTS RMOD eligible for CB010846  ${BTS_alias_shared_RMOD_sn_dict}
    ...  ${BTS_alias_RMOD_sn_RMOD_buildVersion_dict}  ${BTS_alias_RMOD_sn_RMOD_l3Protocol_dict}
    Set Test Variable  ${BTS_alias_CB010846_shared_RMOD_sn_dict}

    ${BTS_alias_CB010846_dedicated_RMOD_sn_dict}=  Get all BTS RMOD eligible for CB010846  ${BTS_alias_dedicated_RMOD_sn_dict}
    ...  ${BTS_alias_RMOD_sn_RMOD_buildVersion_dict}  ${BTS_alias_RMOD_sn_RMOD_l3Protocol_dict}
    Set Test Variable  ${BTS_alias_CB010846_dedicated_RMOD_sn_dict}

    ${BTS_alias_RAT_RMOD_sn_dict}=  Get all BTS RAT configured RMOD list
    Set Test Variable  ${BTS_alias_RAT_RMOD_sn_dict}

    Set Test Variable  ${RMOD_state_disabled_check}
    ...   operationalState=${Disabled_}, availabilityStatus=${NotInstalled_Offline_}, administrativeState=${Unlocked_}
    Set Test Variable  ${RMOD_state_enabled_check}  operationalState=${Enabled_}, administrativeState=${Unlocked_}
    Set Test Variable  ${RMOD_state_disabled}  operationalState=Disabled, availabilityStatus=NotInstalled|Offline, administrativeState=Unlocked
    Set Test Variable  ${RMOD_state_enabled}  operationalState=Enabled, administrativeState=Unlocked

    Set Test Variable  ${CELL_state_disabled_check}  operationalState=${Disabled_}, blockingState=${Unblocked_}
    Set Test Variable  ${CELL_state_disabled}  operationalState=Disabled, blockingState=Unblocked
    Set Test Variable  ${CELL_state_enabled_check}  operationalState=${Enabled_}, blockingState=${Unblocked_}
    Set Test Variable  ${CELL_state_enabled}  operationalState=Enabled, blockingState=Unblocked

Step ${index}: Perform RAT Reset operation on all BTS for iteration ${CYCLE}

    Log  Step ${index}: Perform RAT Reset operation on all BTS for iteration ${CYCLE}  console=True

    FOR  ${alias}  IN  @{alias_list}

        Perform RAT Reset on BTS  ${alias}  ${CYCLE}

    END

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]
    ...  Following checks are performed:
    ...  - number of configured cells and radio modules in SCF are properly mapped on BTS running view ADMIN
    ...  - check cells states
    ...  - check radio modules states

    Log  Step ${index}: Check final number and state of Cells and RMs  console=True
    RFS Test Case Final Checks

Check RAT list
    Get all BTS RAT info

    Return From Keyword If  '${RAT_LIST}' == 'ALL'

    ${RAT_LIST_strip}=  Replace String  ${RAT_LIST}  ${SPACE}  ${EMPTY}
    ${RAT_request_list}=  Split String  ${RAT_LIST_strip}  ,
    Set Test Variable  ${RAT_request_list}

    ${RAT_check}=  Set Variable  True

    FOR  ${alias}  IN  @{alias_list}

        ${BTS_RAT_check}=  Check BTS RAT list  ${alias}

    END

Get all BTS RAT info
    FOR  ${alias}  IN  @{alias_list}

        ${BTS_RAT_list}=  Get BTS RAT info  ${alias}

        Set Test Variable  ${${alias}_BTS_RAT_list}  ${BTS_RAT_list}

    END

Get BTS RAT info
    [Arguments]  ${alias}

    ${BTS_RAT_list}=  Create List

    ${NR_CELL_id_list}=  Get Ids For All  class_name=NRCEL  connection=${alias}
    Set Test Variable  ${${alias}_NR_CELL_id_list}  ${NR_CELL_id_list}
    Run Keyword If  ${NR_CELL_id_list}  Append To List  ${BTS_RAT_list}  NR

    ${LTE_CELL_id_list}=  Get Ids For All  class_name=LNCEL  connection=${alias}
    Set Test Variable  ${${alias}_LTE_CELL_id_list}  ${LTE_CELL_id_list}
    Run Keyword If  ${LTE_CELL_id_list}  Append To List  ${BTS_RAT_list}  LTE

    ${WCDMA_CELL_id_list}=  Get Ids For All  class_name=WNCEL  connection=${alias}
    Set Test Variable  ${${alias}_WCDMA_CELL_id_list}  ${WCDMA_CELL_id_list}
    Run Keyword If  ${WCDMA_CELL_id_list}  Append To List  ${BTS_RAT_list}  WCDMA

    ${GSM_CELL_id_list}=  Get Ids For All  class_name=GNCEL  connection=${alias}
    Set Test Variable  ${${alias}_GSM_CELL_id_list}  ${GSM_CELL_id_list}
    Run Keyword If  ${GSM_CELL_id_list}  Append To List  ${BTS_RAT_list}  GSM

    [Return]  ${BTS_RAT_list}

Check BTS RAT list
    [Arguments]  ${alias}

    ${BTS_RAT_check}=  Set Variable  True
    ${BTS_RAT_invalid_list}=  Create List
    ${BTS_RAT_request_list}=  Create List

    FOR  ${rat}  IN  @{RAT_request_list}

        ${BTS_RAT_check}=  Set Variable If  '${rat}' not in ${${alias}_BTS_RAT_list}  False  ${BTS_RAT_check}

        Run Keyword If  '${rat}' not in ${${alias}_BTS_RAT_list}
        ...  Append To List  ${BTS_RAT_invalid_list}  ${rat}
        ...  ELSE
        ...  Append To List  ${BTS_RAT_request_list}  ${rat}

    END

    Run Keyword If  '${BTS_RAT_check}' == 'False'  Run Keywords
    ...  Log Long String  Following selected RATs for BTS ${alias} are not valid: ${BTS_RAT_invalid_list}. Please select values for test argument
    ...  \${RAT_LIST} from configured RATs: ${${alias}_BTS_RAT_list} or let default value: ALL  level=WARN
    ...  AND  Fail  Improper value for argument!

    Set Test Variable  ${${alias}_BTS_RAT_list}  ${BTS_RAT_request_list}

    [Return]  ${BTS_RAT_check}

Get all BTS shared RMOD info
    [Arguments]  ${BTS_alias_RMOD_sn_dict}  ${shared_RMOD_sn_list}

    ${BTS_alias_shared_RMOD_sn_dict}=  Create Dictionary

    FOR  ${alias}  IN  @{alias_list}

        ${BTS_RMOD_sn_list}=  Get From Dictionary  ${BTS_alias_RMOD_sn_dict}  ${alias}

        ${BTS_shared_RMOD_sn_list}=  Get BTS configured RMOD list  ${BTS_RMOD_sn_list}  ${shared_RMOD_sn_list}

        Set To Dictionary  ${BTS_alias_shared_RMOD_sn_dict}  ${alias}  ${BTS_shared_RMOD_sn_list}

    END

    [Return]  ${BTS_alias_shared_RMOD_sn_dict}

Get all BTS dedicated RMOD info
    [Arguments]  ${BTS_alias_RMOD_sn_dict}  ${dedicated_RMOD_sn_list}

    ${BTS_alias_dedicated_RMOD_sn_dict}=  Create Dictionary

    FOR  ${alias}  IN  @{alias_list}

        ${BTS_RMOD_sn_list}=  Get From Dictionary  ${BTS_alias_RMOD_sn_dict}  ${alias}

        ${BTS_dedicated_RMOD_sn_list}=  Get BTS configured RMOD list  ${BTS_RMOD_sn_list}  ${dedicated_RMOD_sn_list}

        Set To Dictionary  ${BTS_alias_dedicated_RMOD_sn_dict}  ${alias}  ${BTS_dedicated_RMOD_sn_list}

    END

    [Return]  ${BTS_alias_dedicated_RMOD_sn_dict}

Get BTS configured RMOD list
    [Arguments]  ${BTS_RMOD_sn_list}  ${configured_RMOD_sn_list}

    ${BTS_configured_RMOD_sn_list}=  Create List

    FOR  ${RMOD_sn}  IN  @{BTS_RMOD_sn_list}

        Continue For Loop If  '${RMOD_sn}' not in ${configured_RMOD_sn_list}

        Append To List  ${BTS_configured_RMOD_sn_list}  ${RMOD_sn}

    END

    Sort List  ${BTS_configured_RMOD_sn_list}

    [Return]  ${BTS_configured_RMOD_sn_list}

Get all BTS RAT configured RMOD list

    ${BTS_alias_RAT_RMOD_sn_dict}=  Create Dictionary

    FOR  ${alias}  IN  @{alias_list}

        ${BTS_RAT_RMOD_sn_dict}=  Get BTS RAT configured RMOD list  ${alias}

        Set To Dictionary  ${BTS_alias_RAT_RMOD_sn_dict}  ${alias}  ${BTS_RAT_RMOD_sn_dict}

    END

    [Return]  ${BTS_alias_RAT_RMOD_sn_dict}

Get BTS RAT configured RMOD list
    [Arguments]  ${alias}

    ${BTS_NR_RAT_RMOD_sn_list}=  Create List
    ${BTS_LTE_RAT_RMOD_sn_list}=  Create List
    ${BTS_WCDMA_RAT_RMOD_sn_list}=  Create List
    ${BTS_GSM_RAT_RMOD_sn_list}=  Create List

    ${RMOD_sn_list}=  Get From Dictionary  ${BTS_alias_RMOD_sn_dict}  ${alias}

    FOR  ${RMOD_sn}  IN  @{RMOD_sn_list}

        ${NR_RAT_RMOD_sn_list}  ${LTE_RAT_RMOD_sn_list}  ${WCDMA_RAT_RMOD_sn_list}  ${GSM_RAT_RMOD_sn_list}=  Get RAT configured RMOD list
        ...  ${RMOD_sn}  ${alias}
        Append To List  ${BTS_NR_RAT_RMOD_sn_list}  @{NR_RAT_RMOD_sn_list}
        Append To List  ${BTS_LTE_RAT_RMOD_sn_list}  @{LTE_RAT_RMOD_sn_list}
        Append To List  ${BTS_WCDMA_RAT_RMOD_sn_list}  @{WCDMA_RAT_RMOD_sn_list}
        Append To List  ${BTS_GSM_RAT_RMOD_sn_list}  @{GSM_RAT_RMOD_sn_list}

    END
    ${BTS_NR_RAT_RMOD_sn_list}=  Remove Duplicates  ${BTS_NR_RAT_RMOD_sn_list}
    ${BTS_LTE_RAT_RMOD_sn_list}=  Remove Duplicates  ${BTS_LTE_RAT_RMOD_sn_list}
    ${BTS_WCDMA_RAT_RMOD_sn_list}=  Remove Duplicates  ${BTS_WCDMA_RAT_RMOD_sn_list}
    ${BTS_GSM_RAT_RMOD_sn_list}=  Remove Duplicates  ${BTS_GSM_RAT_RMOD_sn_list}

    ${BTS_RAT_RMOD_sn_dict}=  Create Dictionary  NR=${BTS_NR_RAT_RMOD_sn_list}  LTE=${BTS_LTE_RAT_RMOD_sn_list}  WCDMA=${BTS_WCDMA_RAT_RMOD_sn_list}
    ...  GSM=${BTS_GSM_RAT_RMOD_sn_list}

    [Return]  ${BTS_RAT_RMOD_sn_dict}

Get RAT configured RMOD list
    [Arguments]  ${RMOD_sn}  ${alias}

    ${NR_RAT_RMOD_sn_list}=  Create List
    ${LTE_RAT_RMOD_sn_list}=  Create List
    ${WCDMA_RAT_RMOD_sn_list}=  Create List
    ${GSM_RAT_RMOD_sn_list}=  Create List

    ${RMOD_id}=  Get From Dictionary  ${${alias}_MODULE_sn_id_mapping_dict}  ${RMOD_sn}
    ${CELL_id_list}=  Get Cell Mapping By Module Id  module_id=${RMOD_id}  connection=${alias}

    FOR  ${CELL_id}  IN  @{CELL_id_list}

        Run Keyword If  '${CELL_id}' in ${${alias}_NR_CELL_id_list}
        ...  Append To List  ${NR_RAT_RMOD_sn_list}  ${RMOD_sn}
        ...  ELSE IF  '${CELL_id}' in ${${alias}_LTE_CELL_id_list}
        ...  Append To List  ${LTE_RAT_RMOD_sn_list}  ${RMOD_sn}
        ...  ELSE IF  '${CELL_id}' in ${${alias}_WCDMA_CELL_id_list}
        ...  Append To List  ${WCDMA_RAT_RMOD_sn_list}  ${RMOD_sn}
        ...  ELSE IF  '${CELL_id}' in ${${alias}_GSM_CELL_id_list}
        ...  Append To List  ${GSM_RAT_RMOD_sn_list}  ${RMOD_sn}

    END

    [Return]  ${NR_RAT_RMOD_sn_list}  ${LTE_RAT_RMOD_sn_list}  ${WCDMA_RAT_RMOD_sn_list}  ${GSM_RAT_RMOD_sn_list}

Get all BTS RMOD eligible for CB010846
    [Arguments]  ${BTS_alias_RMOD_sn_dict}  ${BTS_alias_RMOD_sn_RMOD_buildVersion_dict}  ${BTS_alias_RMOD_sn_RMOD_l3Protocol_dict}

    ${BTS_alias_CB010846_RMOD_sn_dict}=  Create Dictionary

    FOR  ${alias}  IN  @{alias_list}

        ${RMOD_sn_list}=  Get From Dictionary  ${BTS_alias_RMOD_sn_dict}  ${alias}
        ${RMOD_sn_RMOD_buildVersion_dict}=  Get From Dictionary  ${BTS_alias_RMOD_sn_RMOD_buildVersion_dict}  ${alias}
        ${RMOD_sn_RMOD_l3Protocol_dict}=  Get From Dictionary  ${BTS_alias_RMOD_sn_RMOD_l3Protocol_dict}  ${alias}

        ${CB010846_RMOD_sn_list}=  Get BTS RMOD eligible for CB010846  ${RMOD_sn_list}  ${RMOD_sn_RMOD_buildVersion_dict}
        ...  ${RMOD_sn_RMOD_l3Protocol_dict}

        Set To Dictionary  ${BTS_alias_CB010846_RMOD_sn_dict}  ${alias}   ${CB010846_RMOD_sn_list}

    END

    [Return]  ${BTS_alias_CB010846_RMOD_sn_dict}

Get BTS RMOD eligible for CB010846
    [Arguments]  ${RMOD_sn_list}  ${RMOD_sn_RMOD_buildVersion_dict}  ${RMOD_sn_RMOD_l3Protocol_dict}

    ${CB010846_RMOD_sn_list}=  Create List

    FOR  ${RMOD_sn}  IN  @{RMOD_sn_list}

        ${RMOD_l3Protocol}=  Get From Dictionary  ${RMOD_sn_RMOD_l3Protocol_dict}  ${RMOD_sn}

        Continue For Loop If  '${RMOD_l3Protocol}' not in ['CPRI_RP1', 'ECPRI_MPLANE']

        ${RMOD_buildVersion}=  Get From Dictionary  ${RMOD_sn_RMOD_buildVersion_dict}  ${RMOD_sn}
        ${RMOD_CB010846_excepted}  ${RMOD_SWline}=  Check RMOD exception for CB010846  ${RMOD_buildVersion}

        Continue For Loop If  ${RMOD_CB010846_excepted}

        Append To List  ${CB010846_RMOD_sn_list}  ${RMOD_sn}

    END

    Sort List  ${CB010846_RMOD_sn_list}

    [Return]  ${CB010846_RMOD_sn_list}

Check RMOD exception for CB010846
    [Arguments]  ${RMOD_buildVersion}

    ${RMOD_buildVersion_split_list}=  Split String  ${RMOD_buildVersion}  .

    FOR  ${item}  IN  @{RMOD_CB010846_exceptions}

        ${RMOD_CB010846_excepted}=  Run Keyword And Return Status  List Should Contain Value  ${RMOD_buildVersion_split_list}  ${item}

        Exit For Loop If  ${RMOD_CB010846_excepted}

    END

    ${RMOD_SWline}=  Set Variable  ${item}

    [Return]  ${RMOD_CB010846_excepted}  ${RMOD_SWline}

Check RMOD reset behavior on BTS
    [Arguments]  ${RMOD_sn_list}  ${alias}

    ${RMOD_sn_Uptime_dict_initial}=  Get From Dictionary  ${BTS_alias_RMOD_sn_Uptime_dict_initial}  ${alias}
    ${RMOD_sn_Uptime_dict_final}=  Get From Dictionary  ${BTS_alias_RMOD_sn_Uptime_dict_final}  ${alias}

    Check RMODs RESET behavior based on Uptime info on BTS  RMOD_sn_list=${RMOD_sn_list}
    ...  RMOD_sn_Uptime_dict_initial=${RMOD_sn_Uptime_dict_initial}  RMOD_sn_Uptime_dict_final=${RMOD_sn_Uptime_dict_final}  alias=${alias}

Get all BTS Modules SN ID mapping

    FOR  ${alias}  IN  @{alias_list}

        ${MODULE_sn_id_mapping_dict}=  Get All Modules SN ID mapping  ${alias}
        Set Test Variable  ${${alias}_MODULE_sn_id_mapping_dict}  ${MODULE_sn_id_mapping_dict}

    END

Perform RAT Reset on BTS
    [Arguments]  ${alias}  ${CYCLE}

    FOR  ${rat}  IN  @{${alias}_BTS_RAT_list}

        Perform RAT Reset  ${rat}  ${alias}

        Check all BTS requested RMOD reset behavior based on Uptime info  ${rat}  ${alias}

        Check all BTS reset behavior based on IMS info  ${alias}

        Get and check KPI from IMS file  ${rat}  ${alias}  ${CYCLE}

    END

Perform RAT Reset
    [Arguments]  ${rat}  ${alias}

    ${peer_alias}=  Set Variable If  '${alias}' == 'Master'  Slave  Master

    ${CELL_class_name}=  Set Variable If  '${rat}'=='NR'  NRCEL  '${rat}'=='LTE'  LNCEL  '${rat}'=='WCDMA'  WNCEL  '${rat}'=='GSM'  GNCEL
    ${RESET_WRN_THR}=  Set Variable  ${${rat}_RESET_WRN_THR}

    Log  ***** Perform "Reset ${rat}" RAT operation on BTS ${alias} *****  console=True

    Get shared RMOD Primary Link Info

    Get BTS and peer BTS RAT reset impact  ${rat}  ${alias}  ${peer_alias}

    ${CB010846_RAT_shared_RMOD_count}=  Get Length  ${CB010846_RAT_shared_RMOD_sn_list}

    Run Keyword If  ${CB010846_RAT_shared_RMOD_count} > 0  Run Keywords
    ...  Log  Get Primary Link status (linkModeSynchronization) for ${rat} RAT shared RMODs eligible for CB010846:  console=True
    ...  AND  Get shared RMOD synchronisation info on both BTS  shared_RMOD_sn_list=${CB010846_RAT_shared_RMOD_sn_list}

    ${BTS_alias_RMOD_sn_Uptime_dict_initial}=  Get all BTS RMOD Uptime info
    Set Test Variable  ${BTS_alias_RMOD_sn_Uptime_dict_initial}

    ${new_alias}=  Set Variable  resetRAT
    Get Current Date UTC info  start_resetRAT
    Get Current Time  initial
    Start new ADMIN instance  alias=${alias}  new_alias=${new_alias}  connection_type=${connection_type_${alias}}
    ${reset_info}=  Run Keyword In Background  Rat Reset  rat_type=${rat}  timeout=${RAT_MAX_WAIT_TIME}  connection=${new_alias}
    ...  graceful_cell_shutdown=${GRACEFUL_CELL_SHUTDOWN}  reset_type=Hard

    Check BTS state and alarms during RAT reset  ${rat}  ${CELL_class_name}  ${alias}

    Check peer BTS state and alarms during RAT reset  ${rat}  ${alias}  ${peer_alias}

    Collect Keyword Result  ${reset_info}  timeout=${RAT_MAX_WAIT_TIME}

    Check BTS state and alarms after RAT reset  ${rat}  ${CELL_class_name}  ${alias}

    Check all BTS state and alarms after RAT reset  ${rat}

    Sleep  60s  reason=Allow RMOD uptime update in BTS after RAT reset
    Get Current Date UTC info  end_resetRAT

    Run Keyword If  ${${peer_alias}_CB007447_status}
    ...  Check peer BTS CPRI shared RMODs status with CB007447 feature activated  ${peer_BTS_CPRI_shared_RMOD_id_list}
    ...  ${date_timestamp_start_resetRAT_UTC}  ${date_timestamp_end_resetRAT_UTC}  ${peer_alias}

    [Teardown]  Teardown Admin  alias=${new_alias}

Get shared RMOD Primary Link Info
    [Documentation]
    ...  Get shared RMOD Primary Link Info

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
    [Arguments]  ${rat}  ${alias}  ${peer_alias}

    Get BTS RAT reset impact on FRONTHAUL modules and cells  ${rat}  ${alias}
    Get peer RMOD and cells impacted by RAT reset  ${rat}  ${alias}  ${peer_alias}

    ${CB010846_RAT_shared_RMOD_sn_list}  ${CB010846_RAT_dedicated_RMOD_sn_list}=  Get RAT RMOD eligible for CB010846  ${rat}  ${alias}
    Set Test Variable  ${CB010846_RAT_shared_RMOD_sn_list}
    Set Test Variable  ${CB010846_RAT_dedicated_RMOD_sn_list}

Get BTS RAT reset impact on FRONTHAUL modules and cells
    [Arguments]  ${rat}  ${alias}

    ${RAT_reset_FHS_id_list}  ${RAT_reset_RMOD_id_list}  ${RAT_reset_NRCEL_id_list}  ${RAT_reset_LNCEL_id_list}  ${RAT_reset_WNCEL_id_list}
    ...  ${RAT_reset_GNCEL_id_list}=  Get RAT reset impact on FRONTHAUL modules and cells  ${rat}  ${alias}

    ${BTS_alias_RMOD_sn_list}=  Get From Dictionary  ${BTS_alias_RMOD_sn_dict}  ${alias}

    ${RAT_reset_RMOD_sn_list}=  Create List

    FOR  ${RMOD_sn}  IN  @{BTS_alias_RMOD_sn_list}

        ${RMOD_id}=  Get From Dictionary  ${${alias}_MODULE_sn_id_mapping_dict}  ${RMOD_sn}
        Continue For Loop If  '${RMOD_id}' not in ${RAT_reset_RMOD_id_list}

        Append To List  ${RAT_reset_RMOD_sn_list}  ${RMOD_sn}

    END

    Set Test Variable  ${${alias}_${rat}_RAT_reset_RMOD_id_list}  ${RAT_reset_RMOD_id_list}
    Set Test Variable  ${${alias}_${rat}_RAT_reset_RMOD_sn_list}  ${RAT_reset_RMOD_sn_list}
    Set Test Variable  ${${alias}_${rat}_RAT_reset_NRCEL_id_list}  ${RAT_reset_NRCEL_id_list}
    Set Test Variable  ${${alias}_${rat}_RAT_reset_LNCEL_id_list}  ${RAT_reset_LNCEL_id_list}
    Set Test Variable  ${${alias}_${rat}_RAT_reset_WNCEL_id_list}  ${RAT_reset_WNCEL_id_list}
    Set Test Variable  ${${alias}_${rat}_RAT_reset_GNCEL_id_list}  ${RAT_reset_GNCEL_id_list}

Get peer RMOD and cells impacted by RAT reset
    [Arguments]  ${rat}  ${alias}  ${peer_alias}

    ${peer_CPRI_impacted_RMOD_list}=  Create List
    ${peer_ECPRI_impacted_RMOD_list}=  Create List
    ${peer_OBSAI_impacted_RMOD_list}=  Create List
    ${peer_not_impacted_RMOD_list}=  Create List

    ${BTS_alias_shared_RMOD_sn_list}=  Get From Dictionary  ${BTS_alias_shared_RMOD_sn_dict}  ${alias}

    FOR  ${RMOD_sn}  IN  @{${alias}_${rat}_RAT_reset_RMOD_sn_list}

        Continue For Loop If  '${RMOD_sn}' not in ${BTS_alias_shared_RMOD_sn_list}

        ${peer_RMOD_id}=  Get From Dictionary  ${${peer_alias}_MODULE_sn_id_mapping_dict}  ${RMOD_sn}

        Run Keyword If  '${peer_RMOD_id}' in @{${peer_alias}_non_PL_not_excepted_ECPRI_shared_RMOD_list}
        ...  Append To List  ${peer_ECPRI_impacted_RMOD_list}  ${peer_RMOD_id}
        ...  ELSE IF  '${peer_RMOD_id}' in @{${peer_alias}_non_PL_OBSAI_shared_RMOD_list}
        ...  Append To List  ${peer_OBSAI_impacted_RMOD_list}  ${peer_RMOD_id}
        ...  ELSE IF  '${peer_RMOD_id}' in @{${peer_alias}_non_PL_CPRI_shared_RMOD_list}
        ...  Append To List  ${peer_CPRI_impacted_RMOD_list}  ${peer_RMOD_id}
        ...  ELSE
        ...  Append To List  ${peer_not_impacted_RMOD_list}  ${peer_RMOD_id}

    END

    ${peer_impacted_RMOD_list_full}=  Combine Lists  ${peer_CPRI_impacted_RMOD_list}  ${peer_ECPRI_impacted_RMOD_list}
    ...  ${peer_OBSAI_impacted_RMOD_list}
    ${peer_impacted_RMOD_list_full}=  Remove Duplicates  ${peer_impacted_RMOD_list_full}

    ${peer_BTS_CPRI_shared_RMOD_id_list}=  Run Keyword If  ${${peer_alias}_CB007447_status}
    ...  Combine Lists  ${${peer_alias}_PL_CPRI_shared_RMOD_list}  ${${peer_alias}_non_PL_CPRI_shared_RMOD_list}

    ${peer_non_impacted_RMOD_list_full}=  Combine Lists  ${${peer_alias}_PL_ECPRI_shared_RMOD_list}  ${${peer_alias}_PL_CPRI_shared_RMOD_list}
    ...  ${${peer_alias}_PL_OBSAI_shared_RMOD_list}  ${peer_not_impacted_RMOD_list}

    Run Keyword If  ${${peer_alias}_CB007447_status}  Append To List  ${peer_non_impacted_RMOD_list_full}  @{peer_BTS_CPRI_shared_RMOD_id_list}
    ${peer_non_impacted_RMOD_list_full}=  Remove Duplicates  ${peer_non_impacted_RMOD_list_full}

    Set Test Variable  ${peer_CPRI_impacted_RMOD_list}
    Set Test Variable  ${peer_ECPRI_impacted_RMOD_list}
    Set Test Variable  ${peer_OBSAI_impacted_RMOD_list}
    Set Test Variable  ${peer_impacted_RMOD_list_full}
    Set Test Variable  ${peer_non_impacted_RMOD_list_full}
    Set Test Variable  ${peer_BTS_CPRI_shared_RMOD_id_list}

Get RAT RMOD eligible for CB010846
    [Arguments]  ${rat}  ${alias}

    ${CB010846_RAT_shared_RMOD_sn_list}=  Create List
    ${CB010846_RAT_dedicated_RMOD_sn_list}=  Create List

    ${CB010846_shared_RMOD_sn_list}=  Get From Dictionary  ${BTS_alias_CB010846_shared_RMOD_sn_dict}  ${alias}
    ${CB010846_dedicated_RMOD_sn_list}=  Get From Dictionary  ${BTS_alias_CB010846_dedicated_RMOD_sn_dict}  ${alias}
    ${BTS_RAT_RMOD_sn_dict}=  Get From Dictionary  ${BTS_alias_RAT_RMOD_sn_dict}  ${alias}
    ${RAT_RMOD_sn_list}=  Get From Dictionary  ${BTS_RAT_RMOD_sn_dict}  ${rat}

    FOR  ${RMOD_sn}  IN  @{CB010846_shared_RMOD_sn_list}

        Run Keyword If  '${RMOD_sn}' in ${RAT_RMOD_sn_list}
        ...  Append To List  ${CB010846_RAT_shared_RMOD_sn_list}  ${RMOD_sn}

    END

    FOR  ${RMOD_sn}  IN  @{CB010846_dedicated_RMOD_sn_list}

        Run Keyword If  '${RMOD_sn}' in ${RAT_RMOD_sn_list}
        ...  Append To List  ${CB010846_RAT_dedicated_RMOD_sn_list}  ${RMOD_sn}

    END

    [Return]  ${CB010846_RAT_shared_RMOD_sn_list}  ${CB010846_RAT_dedicated_RMOD_sn_list}

Get shared RMOD synchronisation info on both BTS
    [Arguments]  ${shared_RMOD_sn_list}

    ${shared_RMOD_sn_BTS_alias_linkModeSynchronization_info_dict}=  Create Dictionary

     FOR  ${RMOD_sn}  IN  @{shared_RMOD_sn_list}

        ${BTS_alias_linkModeSynchronization_info_dict}  ${RMOD_interface}=  Get shared RMOD synchronisation info  ${RMOD_sn}

    END

    [Return]  ${shared_RMOD_sn_BTS_alias_linkModeSynchronization_info_dict}

Get shared RMOD synchronisation info
    [Arguments]  ${RMOD_sn}

    ${RMOD_alias_list}=  Get From Dictionary  ${RMOD_sn_BTS_alias_dict}  ${RMOD_sn}
    ${BTS_alias_linkModeSynchronization_info_dict}=  Create Dictionary

    Log  RMOD_${RMOD_sn} linkModeSynchronization info:  console=True

    FOR  ${alias}  IN  @{RMOD_alias_list}

        ${RMOD_linkModeSynchronization}  ${RMOD_interface}=  Get classical BTS RMOD synchronisation info from SCF  ${RMOD_sn}  ${alias}
        Log  - BTS ${alias} (${RMOD_interface}): ${RMOD_linkModeSynchronization}  console=True

        Set To Dictionary  ${BTS_alias_linkModeSynchronization_info_dict}  ${alias}  ${RMOD_linkModeSynchronization}

    END

    [Return]  ${BTS_alias_linkModeSynchronization_info_dict}  ${RMOD_interface}

Check BTS state and alarms during RAT reset
    [Arguments]  ${rat}  ${CELL_class_name}  ${alias}

    Log  Check BTS ${alias} state and alarms during BTS ${alias} ${rat} RAT reset  console=True

    Log  Check BTS ${alias} ${rat} cells status:  console=True
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_initial}  ${RAT_MAX_WAIT_TIME}
    Assert Every  class_name=${CELL_class_name}  parameters=${CELL_state_disabled_check}  timeout=${remained_MAX_WAIT_TIME}  connection=${alias}
    Log  BTS ${alias} ${rat} cells status:\n - ${CELL_state_disabled}  console=True

    Check BTS FRONTHAUL modules and cells status impacted by RAT reset  ${rat}  ${alias}

Check BTS FRONTHAUL modules and cells status impacted by RAT reset
    [Arguments]  ${rat}  ${alias}

    Log  Check BTS ${alias} RMODs status impacted by ${rat} RAT reset:  console=True

    FOR  ${RMOD_id}  IN  @{${alias}_${rat}_RAT_reset_RMOD_id_list}

        ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_initial}  ${RAT_MAX_WAIT_TIME}
        Assert  class_name=RMOD  id=${RMOD_id}  parameters=${RMOD_state_disabled_check}  timeout=${remained_MAX_WAIT_TIME}  connection=${alias}
        Log  BTS ${alias} RMOD ${RMOD_id} status:\n - ${RMOD_state_disabled}  console=True

    END

    Log  Check BTS ${alias} other RAT cells status impacted by ${rat} RAT reset:  console=True

    Run Keyword If  ${${alias}_${rat}_RAT_reset_NRCEL_id_list} and '${rat}' != 'NR'
    ...  Check NR cells state and MIMO alarm  cell_list=${${alias}_${rat}_RAT_reset_NRCEL_id_list}  alias=${alias}
    ...  ELSE IF  '${rat}' != 'NR'
    ...  Log  No BTS ${alias} NR cells with impact status  console=True

    Run Keyword If  ${${alias}_${rat}_RAT_reset_LNCEL_id_list} and '${rat}' != 'LTE'
    ...  Check LTE cells state and MIMO alarm  cell_list=${${alias}_${rat}_RAT_reset_LNCEL_id_list}  alias=${alias}
    ...  ELSE IF  '${rat}' != 'LTE'
    ...  Log  No BTS ${alias} LTE cells with impact status  console=True

    Run Keyword If  ${${alias}_${rat}_RAT_reset_WNCEL_id_list} and '${rat}' != 'WCDMA'
    ...  Check WCDMA cells state and MIMO alarm  cell_list=${${alias}_${rat}_RAT_reset_WNCEL_id_list}  alias=${alias}
    ...  ELSE IF  '${rat}' != 'WCDMA'
    ...  Log  No BTS ${alias} WCDMA cells with impact status  console=True

    Run Keyword If  ${${alias}_${rat}_RAT_reset_GNCEL_id_list} and '${rat}' != 'GSM'
    ...  Check GSM cells state and MIMO alarm  cell_list=${${alias}_${rat}_RAT_reset_GNCEL_id_list}  alias=${alias}
    ...  ELSE IF  '${rat}' != 'GSM'
    ...  Log  No BTS ${alias} GSM cells with impact status  console=True

Check peer BTS state and alarms during RAT reset
    [Arguments]  ${rat}  ${alias}  ${peer_alias}

    Log  Check BTS ${peer_alias} state and alarms during BTS ${alias} ${rat} RAT reset  console=True

    Log  Check BTS ${peer_alias} shared RMODs without impact status:  console=True
    Run Keyword If  ${peer_non_impacted_RMOD_list_full}  Run Keywords
    ...  Check BTS Item State  RMOD  ${peer_non_impacted_RMOD_list_full}  ${RMOD_state_enabled_check}  ${RMOD_state_enabled}  5  ${peer_alias}
    ...  AND  Log  All BTS ${peer_alias} shared RMODs without impact status as expected  console=True
    ...  ELSE
    ...  Log  No BTS ${peer_alias} shared RMODs without impact status  console=True

    Log  Check BTS ${peer_alias} shared CPRI RMODs with impact status:  console=True
    Run Keyword If  ${peer_CPRI_impacted_RMOD_list} and not ${${peer_alias}_CB007447_status}
    ...  Check BTS Item State  RMOD  ${peer_CPRI_impacted_RMOD_list}  ${RMOD_state_disabled_check}  ${RMOD_state_disabled}  300  ${peer_alias}
    ...  ELSE
    ...  Log  No BTS ${peer_alias} shared CPRI RMODs with impact status  console=True

    Log  Check BTS ${peer_alias} shared ECPRI RMODs with impact status:  console=True
    Run Keyword If  ${peer_ECPRI_impacted_RMOD_list}
    ...  Check BTS Item State  RMOD  ${peer_ECPRI_impacted_RMOD_list}  ${RMOD_state_disabled_check}  ${RMOD_state_disabled}  300  ${peer_alias}
    ...  ELSE
    ...  Log  No BTS ${peer_alias} shared ECPRI RMODs with impact status  console=True

    Log  Check BTS ${peer_alias} shared OBSAI RMODs with impact status:  console=True
    Run Keyword If  ${peer_OBSAI_impacted_RMOD_list}
    ...  Check BTS Item State  RMOD  ${peer_OBSAI_impacted_RMOD_list}  ${RMOD_state_disabled_check}  ${RMOD_state_disabled}  300  ${peer_alias}
    ...  ELSE
    ...  Log  No BTS ${peer_alias} shared OBSAI RMODs with impact status  console=True

    ${peer_alarm_10_count}=  Get Length  ${peer_OBSAI_impacted_RMOD_list}
    ${peer_alarm_10_1815_count}=  Run Keyword If  ${${peer_alias}_CB007447_status}
    ...  Set Variable  0
    ...  ELSE
    ...  Get Length  ${peer_CPRI_impacted_RMOD_list}
    ${peer_alarm_16_count}=  Get Length  ${peer_ECPRI_impacted_RMOD_list}
    ${peer_EXPECTED_ALARMS}=  Create List
    ${EXPECTED_ALARMS_10_full}=  Prepare expected alarms list  ${test_alarms_list['${peer_alias.upper()}_EXPECTED_ALARMS_10']}  ${peer_alarm_10_count}
    ${EXPECTED_ALARMS_10_1815_full}=  Prepare expected alarms list  ${test_alarms_list['${peer_alias.upper()}_EXPECTED_ALARMS_10_1815']}
    ...  ${peer_alarm_10_1815_count}
    ${EXPECTED_ALARMS_16_full}=  Prepare expected alarms list  ${test_alarms_list['${peer_alias.upper()}_EXPECTED_ALARMS_16']}  ${peer_alarm_16_count}
    ${peer_EXPECTED_ALARMS_full}=  Combine Lists  ${EXPECTED_ALARMS_10_full}  ${EXPECTED_ALARMS_10_1815_full}  ${EXPECTED_ALARMS_16_full}
    ${peer_IGNORED_ALARMS_full}=  Combine Lists  ${test_alarms_list['${peer_alias.upper()}_IGNORED_ALARMS']}
    ...  ${test_alarms_list['${peer_alias.upper()}_IGNORED_ALARMS_DURING_RESET']}

    Run Keyword If  ${peer_alarm_10_count} > 0
    ...  Log  BTS ${peer_alias} "No connection to unit (10)" alarm, expected number: ${peer_alarm_10_count}  console=True
    Run Keyword If  ${peer_alarm_10_1815_count} > 0 and not ${${peer_alias}_CB007447_status}
    ...  Log Long String  BTS ${peer_alias} "Not able to synchronize baseband bus (1815)" or "No connection to unit (10)" alarm,
    ...  expected number: ${peer_alarm_10_1815_count}  console=True
    Run Keyword If  ${peer_alarm_16_count} > 0
    ...  Log  BTS ${peer_alias} "Unit synchronization failed (16)" alarm, expected number: ${peer_alarm_16_count}  console=True

    Get and Check Alarms SOAM  alias=${peer_alias}  expected_alarms=${peer_EXPECTED_ALARMS_full}  poll_interval=3 sec
    ...  ignored_alarms=${peer_IGNORED_ALARMS_full}  critical_alarms=${test_alarms_list['${peer_alias.upper()}_CRITICAL_ALARMS']}

    Run Keyword If  ${peer_alarm_10_count} > 0
    ...  Log  BTS ${peer_alias} "No connection to unit (10)" alarm, found number: ${peer_alarm_10_count}, as expected!  console=True
    Run Keyword If  ${peer_alarm_10_1815_count} > 0 and not ${${peer_alias}_CB007447_status}
    ...  Log Long String  BTS ${peer_alias} "Not able to synchronize baseband bus (1815)" or "No connection to unit (10)" alarm,
    ...  found number: ${peer_alarm_10_1815_count}, as expected!  console=True
    Run Keyword If  ${peer_alarm_16_count} > 0
    ...  Log  BTS ${peer_alias} "Unit synchronization failed (16)" alarm, found number: ${peer_alarm_16_count}, as expected!  console=True

    Log  BTS ${peer_alias} site - expected, ignored and critical alarms checked  console=True

Check BTS state and alarms after RAT reset
    [Arguments]  ${rat}  ${CELL_class_name}  ${alias}

    Log  Check BTS ${alias} states and alarms after BTS ${alias} ${rat} RAT reset:  console=True

    Log  Check BTS ${alias} ${rat} cells status  console=True
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_initial}  ${RAT_MAX_WAIT_TIME}
    Assert Every  class_name=${CELL_class_name}  parameters=${CELL_state_enabled_check}  timeout=${remained_MAX_WAIT_TIME}  connection=${alias}
    Log  BTS ${alias} ${rat} cells status:\n - ${CELL_state_enabled}  console=True

    Log  Check BTS ${alias} RMOD(s) status  console=True
    ${BTS_RAT_RMOD_sn_dict}=  Get From Dictionary  ${BTS_alias_RAT_RMOD_sn_dict}  ${alias}
    ${RAT_RMOD_sn_list}=  Get From Dictionary  ${BTS_RAT_RMOD_sn_dict}  ${rat}
    FOR  ${RMOD_sn}  IN  @{RAT_RMOD_sn_list}

        ${RMOD_id}=  Get From Dictionary  ${${alias}_MODULE_sn_id_mapping_dict}  ${RMOD_sn}
        ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_initial}  ${RAT_MAX_WAIT_TIME}
        Assert  class_name=RMOD  id=${RMOD_id}  parameters=${RMOD_state_enabled_check}  timeout=${remained_MAX_WAIT_TIME}  connection=${alias}
        Log  BTS ${alias} RMOD ${RMOD_id} status:\n - ${RMOD_state_enabled}  console=True

    END

    Log  Check alarms on BTS ${alias}  console=True
    Get and Check Alarms SOAM  alias=${alias}  expected_alarms=@{EMPTY}  ignored_alarms=${test_alarms_list['${alias.upper()}_IGNORED_ALARMS']}
    ...  critical_alarms=${test_alarms_list['${alias.upper()}_CRITICAL_ALARMS']}
    Log  BTS ${alias} site - expected, ignored and critical alarms checked  console=True

Check all BTS state and alarms after RAT reset
    [Arguments]  ${rat}

    FOR  ${alias}  IN  @{alias_list}

        Log  Check BTS ${alias} states and alarms after BTS ${alias} ${rat} RAT reset:  console=True

        Log  Check BTS ${alias} status  console=True
        Admin Check BTS Procedural and Blocking states  ${OnAir_}  ${Unblocked_}  ${RAT_MAX_WAIT_TIME}  ${alias}
        Log  BTS ${alias} status:\n - proceduralState: OnAir, blockingState: Unblocked  console=True

        Log  Check RMOD(s) status on BTS ${alias}  console=True
        Assert Every  class_name=RMOD  parameters=${RMOD_state_enabled_check}  timeout=${RAT_MAX_WAIT_TIME}  connection=${alias}
        Log  BTS ${alias} RMOD(s) status:\n - ${RMOD_state_enabled}  console=True

        Log  Check CELL(s) status on BTS ${alias}  console=True
        Check cells availability status online  ${alias}  ${RAT_MAX_WAIT_TIME}
        Log  BTS ${alias} cells status:\n - ${CELL_state_enabled}  console=True

        Log  Check alarms on BTS ${alias}  console=True
        Get and Check Alarms SOAM  alias=${alias}  expected_alarms=@{EMPTY}  ignored_alarms=${test_alarms_list['${alias.upper()}_IGNORED_ALARMS']}
        ...  critical_alarms=${test_alarms_list['${alias.upper()}_CRITICAL_ALARMS']}
        Log  BTS ${alias} site - expected, ignored and critical alarms checked  console=True

    END

Check peer BTS CPRI shared RMODs status with CB007447 feature activated
    [Arguments]  ${CPRI_shared_RMOD_id_list}  ${date_timestamp_start_UTC}  ${date_timestamp_end_UTC}  ${alias}

    Log  Check BTS ${alias} CPRI shared RMODs status with CB007447 feature activated:  console=True

    ${RMOD_status_dict}=  Create Dictionary  operationalState=enabled
    ${ims_file_path}=  Admin Collect IMS file with timestamp  folder_path=${Test Results Dir}/IMS/${alias}  alias=${alias}

    FOR  ${RMOD_id}  IN  @{CPRI_shared_RMOD_id_list}

        Check object parameters values are not changed from IMS file  ims_file_path=${ims_file_path}  obj_dist_name=${RMOD_id}
        ...  obj_parameter_dict=${RMOD_status_dict}  start_point_timestamp_UTC=${date_timestamp_start_UTC}
        ...  end_point_timestamp_UTC=${date_timestamp_end_UTC}  allow_no_updates=${TRUE}

    END

    Log  BTS ${alias} CPRI shared RMODs status with CB007447 feature activated as expected  console=True

Check BTS Item State
    [Arguments]  ${BTS_item_class}  ${BTS_item_list}  ${BTS_item_state_check}  ${BTS_item_state}  ${timeout}  ${alias}

    FOR  ${item}  IN  @{BTS_item_list}

        Assert  class_name=${BTS_item_class}  id=${item}  parameters=${BTS_item_state_check}  timeout=${timeout}  connection=${alias}
        Log  BTS ${alias} ${BTS_item_class} ${item} status:\n - ${BTS_item_state}  console=True

    END

Check all BTS reset behavior based on IMS info
    [Documentation]
    ...  BTS RESET info is checked based on IMS info. Reset behavior as expected if no BTS reset occurs.
    ...  Otherwise, reset behavior not as expected, then errors are added to report and failed.
    [Arguments]  ${alias}

    Log  Check all BTS reset behavior based on IMS info  console=True

    Get and check BTS RESET info from IMS file  expected_reset_number=0  alias=${alias}
    ...  start_point_timestamp_UTC=${date_timestamp_start_resetRAT_UTC}  end_point_timestamp_UTC=${date_timestamp_end_resetRAT_UTC}

    FOR  ${other_alias}  IN  @{alias_list}

        Continue For Loop If  '${other_alias}' == '${alias}'

        Get and check BTS RESET info from IMS file  expected_reset_number=0  alias=${other_alias}
        ...  start_point_timestamp_UTC=${date_timestamp_start_resetRAT_UTC}  end_point_timestamp_UTC=${date_timestamp_end_resetRAT_UTC}

    END

Check all BTS requested RMOD reset behavior based on Uptime info
    [Documentation]
    ...  Shared and dedicated RMOD RESET behavior is checked based on Uptime info get from BTS. RMOD reset behavior as expected if:
    ...  - RMOD on all BTS: no reset if RU is eligible for CB010846 feature
    ...  Otherwise, reset behavior not as expected, then errors are added to report and failed.
    [Arguments]  ${rat}  ${alias}

    Log  Check all BTS requested RMOD reset behavior based on Uptime info  console=True

    ${BTS_alias_RMOD_sn_Uptime_dict_final}=  Get all BTS RMOD Uptime info
    Set Test Variable  ${BTS_alias_RMOD_sn_Uptime_dict_final}

    Log  Check BTS ${alias} ${rat} RAT shared RMOD eligible for CB010846 feature reset behavior based on Uptime info  console=True

    ${CB010846_RAT_shared_RMOD_count}=  Get Length  ${CB010846_RAT_shared_RMOD_sn_list}

    Run Keyword If  ${CB010846_RAT_shared_RMOD_count} > 0
    ...  Check RMOD reset behavior on BTS  RMOD_sn_list=${CB010846_RAT_shared_RMOD_sn_list}  alias=${alias}
    ...  ELSE
    ...  Log  No ${rat} RAT shared RMODs eligible for CB010846 feature on BTS ${alias}  console=True

    Log  Check BTS ${alias} RAT dedicated RMOD eligible for CB010846 feature reset behavior based on Uptime info  console=True

    ${CB010846_RAT_dedicated_RMOD_count}=  Get Length  ${CB010846_RAT_dedicated_RMOD_sn_list}

    Run Keyword If  ${CB010846_RAT_dedicated_RMOD_count} > 0
    ...  Check RMOD reset behavior on BTS  RMOD_sn_list=${CB010846_RAT_dedicated_RMOD_sn_list}  alias=${alias}
    ...  ELSE
    ...  Log  No RAT dedicated RMODs eligible for CB010846 feature on BTS ${alias}  console=True

    FOR  ${other_alias}  IN  @{alias_list}

        Continue For Loop If  '${other_alias}' == '${alias}'

        Log  Check BTS ${other_alias} shared RMODs eligible for CB010846 feature reset behavior based on Uptime info  console=True

        ${BTS_peer_CB010846_RAT_shared_RMOD_sn_list}=  Get peer BTS shared RMOD  ${CB010846_RAT_shared_RMOD_sn_list}  ${other_alias}
        ${BTS_peer_CB010846_shared_RMOD_sn_count}=  Get Length  ${BTS_peer_CB010846_RAT_shared_RMOD_sn_list}

        ${BTS_peer_CB010846_RAT_shared_RMOD_sn_count}=  Get Length  ${BTS_peer_CB010846_RAT_shared_RMOD_sn_list}

        Run Keyword If  ${BTS_peer_CB010846_RAT_shared_RMOD_sn_count} > 0
        ...  Check RMOD reset behavior on BTS  RMOD_sn_list=${BTS_peer_CB010846_RAT_shared_RMOD_sn_list}  alias=${other_alias}
        ...  ELSE
        ...  Log  No shared RMODs eligible for CB010846 feature configured on BTS ${other_alias}  console=True

        Log  Check BTS ${other_alias} dedicated RMODs reset behavior based on Uptime info  console=True
        ${dedicated_RMOD_sn_list}=  Get From Dictionary  ${BTS_alias_dedicated_RMOD_sn_dict}  ${other_alias}
        ${dedicated_RMOD_count}=  Get Length  ${dedicated_RMOD_sn_list}

        Run Keyword If  ${dedicated_RMOD_count} > 0
        ...  Check RMOD reset behavior on BTS  RMOD_sn_list=${dedicated_RMOD_sn_list}  alias=${other_alias}
        ...  ELSE
        ...  Log  No dedicated RMODs configured on BTS ${other_alias}  console=True

    END

    Run Keyword If  ${CB010846_RAT_shared_RMOD_count} > 0  Run Keywords
    ...  Log  Get Primary Link status (linkModeSynchronization) for ${rat} RAT shared RMODs eligible for CB010846:  console=True
    ...  AND  Get shared RMOD synchronisation info on both BTS  shared_RMOD_sn_list=${CB010846_RAT_shared_RMOD_sn_list}

Get peer BTS shared RMOD
    [Arguments]  ${BTS_shared_RMOD_sn_list}  ${alias}

    ${BTS_peer_shared_RMOD_sn_list}=  Create List
    ${BTS_alias_shared_RMOD_sn_list}=  Get From Dictionary  ${BTS_alias_shared_RMOD_sn_dict}  ${alias}

    FOR  ${RMOD_sn}  IN  @{BTS_alias_shared_RMOD_sn_list}

        Continue For Loop If  '${RMOD_sn}' not in ${BTS_shared_RMOD_sn_list}

        Append To List  ${BTS_peer_shared_RMOD_sn_list}  ${RMOD_sn}

    END

    Sort List  ${BTS_peer_shared_RMOD_sn_list}

    [Return]  ${BTS_peer_shared_RMOD_sn_list}

Get and check KPI from IMS file
    [Arguments]  ${rat}  ${alias}  ${CYCLE}
    ${rat_kpi}=  Set Variable If  '${rat}'=='NR'  kpi10  '${rat}'=='LTE'  kpi7  '${rat}'=='WCDMA'  kpi8  '${rat}'=='GSM'  kpi9

    ${kpi_name_delta_dict}=  Get and check KPI info from IMS file  kpi_names=${rat_kpi}  kpi_thresholds=${${rat}_RESET_WRN_THR}  alias=${alias}
    ...  start_point_timestamp_UTC=${date_timestamp_start_resetRAT_UTC}  end_point_timestamp_UTC=${date_timestamp_end_resetRAT_UTC}
    ${kpi_delta_list}=  Get From Dictionary  ${kpi_name_delta_dict}  ${rat_kpi}

    Export KPI Results to File  alias=${alias}  obj_info=RAT  obj=BTS KPI measurement  obj_type=${rat}  obj_id=${alias}  action_1=RAT_Reset
    ...  kpi_reported_1=${rat_kpi}  event_value_1=${kpi_delta_list[0]}  cycle=${CYCLE}  source_info=ims  add_info_label=RAT_Reset action
    ...  add_info_value=${alias}

TC Setup
    ${tech_preset_list}=  Create List  SBTS  SBTS
    Common Test Setup  PrecheckSCF=${FALSE}  preset_techs=${tech_preset_list}  common_sbts=${TRUE}  infomodelSetup=${FALSE}  newAlarmsFormat=${TRUE}

Particular Teardown
    Export KPI results to File Global  kpi_log_file_name=KpiTimeInfo

TC Teardown
    Common Test Teardown
