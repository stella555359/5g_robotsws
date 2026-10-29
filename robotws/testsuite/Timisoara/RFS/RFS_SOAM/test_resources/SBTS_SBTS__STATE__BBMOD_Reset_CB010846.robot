*** Settings ***
Documentation    TC__SBTS_SBTS__STATE__BBMOD_Reset_CB010846
Variables    tc_variables/sbts_sbts__state__bbmod_reset_cb010846_alarms_definitions.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${REPEAT_COUNTER}              3     # Number of BBMOD Reset operations on both BTS, default value 3
${cntrldResetMplaneBreakTime}  420   # Maximum time when Radio Unit tries to re-establish released M-plane connection to BTS after baseband HW reset.
                                     # Should be in range: 220 - 600 (seconds), by default 420
${BTS_PRIMARY_LINK}                  # BTS for primary link set before BBMOD reset, possible values: empty (no set required),
                                     # Master (Master set required) or Slave (Slave set required), default value: empty
${SET_PRIMARY_LINK_PROCEDURE}  LANE  # Procedure for setting BTS_PRIMARY_LINK, possible values: BTS (BTS Reset), LANE (Lock Unlock SFP LANE)
${SET_PRIMARY_LINK_TIME}       720   # Maximum time in seconds to wait for Primary Link set on ${BTS_PRIMARY_LINK}, default value: 720
${NOT_ALLOWED_RESET_BBMOD_LIST}      # BBMOD type list not allowed for Reset operation. Possible values (by default empty):
                                     # - empty: action will be performed on all found BBMOD (found BBMOD reset on each BTS until last BTS from TL)
                                     # - list of not allowed BBMOD type for reset separated by comma labeled (ex. ABIA, ABIL)
${BBMOD_RESET_WRN_THR}         270   # Time (secs) spent between first cell down to last cell up on BBMOD
                                     # Default value: in accordance with KPI5 specifications
${BBMOD_MAX_WAIT_TIME}         900   # Maximum time to wait for BBMOD cells up after reset, by default 900

*** Keywords ***
TC__SBTS_SBTS__STATE__BBMOD_Reset_CB010846
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-28299
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  SBTS-SBTS test case for BBMOD reset one by one, - x times sequence.
    ...  x - value of REPEAT_COUNTER parameter (default: 3)
    ...  The main steps performed for the test are:
    ...  - check initial state and alarms for both BTS
    ...  - get and check CB010846 settings on both BTS
    ...  - get primary link settings for shared RMOD before BBMOD Reset operation on BTS
    ...  - perform BBMOD Reset operation on BTS checking states and alarms on both BTS
    ...  - check reset behavior on all BTS based on IMS info: no BTS reset expected
    ...  - get and check KPI5 info from IMS file
    ...  Pass criteria: BBMOD reset operation work as expected; states and alarms are as expected
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...
    ...  - 05.11.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28299 -
    ...  [CB010846] Improvement - New Testcases : BB Capacity board improvement in reconfiguration and recovery - BBMOD Reset - EST46.5
    ...  - 29.11.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28452 - [CB010846] BBMOD Reset without RU Reset- 7447 fix part
    ...  - 17.11.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30185 - Adapt SBTS_SBTS__STATE__Uncontrolled_L1Soc_Reset_CB010846 with
    ...  ${actForceUnitAutoReset}' == 'false' case when CB007447 is enabled
    ...  - 27.11.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30221 - Remove ${actForceUnitAutoReset}' in tests and KWs related to CB007447
    ...

    Set Tags    CA-STATE    OWNER-florina.stefan@nokia.com    AUTHOR-dinu.olariu@nokia.com    PHASE-QT    SW-SBTS25R2

    TC Preconditions
    Step 1: Check initial all BTS state
    Step 2: Check initial all BTS alarms
    Step 3: Check CB010846 feature settings
    Step 4: Get all BTS info for configured items
    FOR  ${INDEX}  IN RANGE  1  ${REPEAT_COUNTER} + 1
        Log  ==============================================================================  console=True
        Log  Start Cycle ${INDEX} of ${REPEAT_COUNTER}  console=True
        Log  ==============================================================================  console=True
        Step 5: Perform BBMOD Reset operation on all BTS for iteration ${INDEX}
        Step 6: Check final all BTS state
        Step 7: Check final all BTS alarms
        Step 8: Check final number and state of Cells and RMs
    END

    [Teardown]  Particular Teardown

TC Preconditions

    ${all_BTS_BBMOD_check}=  Get all BTS BBMOD info

    Run Keyword If  not ${all_BTS_BBMOD_check}  Run Keywords
    ...  Log  TC Preconditions failed. No BBMOD found on any BTS. Test execution will be stopped!  level=ERROR
    ...  AND  Fail  TC Preconditions failed. No BBMOD found on any BTS. Test execution will be stopped!

    ${NOT_ALLOWED_RESET_BBMOD_LIST}=  Check not allowed reset BBMOD list
    Set Test Variable  ${NOT_ALLOWED_RESET_BBMOD_LIST}

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

    Log  Get CB007447 feature status  console=True

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

    ${BTS_alias_RMOD_sn_dict}  ${RMOD_sn_BTS_alias_dict}  ${shared_RMOD_sn_list}  ${dedicated_RMOD_sn_list}=  Get all BTS RMOD sharing info
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

    Get all BTS BBMOD CELL mapping based on BBPOOL info

    Get all BTS Modules SN ID mapping

    Set Test Variable  ${BBMOD_state_disabled_check}
    ...   operationalState=${Disabled_}, availabilityStatus=${NotInstalled_Offline_}, administrativeState=${Unlocked_}
    Set Test Variable  ${BBMOD_state_enabled_check}  operationalState=${Enabled_}, administrativeState=${Unlocked_}
    Set Test Variable  ${BBMOD_state_disabled}  operationalState=Disabled, availabilityStatus=NotInstalled|Offline, administrativeState=Unlocked
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

Step ${index}: Perform BBMOD Reset operation on all BTS for iteration ${CYCLE}

    Log  Step ${index}: Perform BBMOD Reset operation on all BTS for iteration ${CYCLE}  console=True

    FOR  ${alias}  IN  @{alias_list}

        Perform BBMOD Reset on BTS  ${alias}  ${CYCLE}

    END

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]
    ...  Following checks are performed:
    ...  - number of configured cells and radio modules in SCF are properly mapped on BTS running view ADMIN
    ...  - check cells states
    ...  - check radio modules states

    Log  Step ${index}: Check final number and state of Cells and RMs  console=True
    RFS Test Case Final Checks

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

Check not allowed reset BBMOD list
    ${NOT_ALLOWED_RESET_BBMOD_LIST_isEmpty}=  Set Variable If  '${NOT_ALLOWED_RESET_BBMOD_LIST}' == ''  ${TRUE}  ${FALSE}

    Return From Keyword If  ${NOT_ALLOWED_RESET_BBMOD_LIST_isEmpty}  @{EMPTY}

    ${NOT_ALLOWED_RESET_BBMOD_LIST_strip}=  Replace String  ${NOT_ALLOWED_RESET_BBMOD_LIST}  ${SPACE}  ${EMPTY}
    ${NOT_ALLOWED_RESET_BBMOD_LIST}=  Split String  ${NOT_ALLOWED_RESET_BBMOD_LIST_strip}  ,

    [Return]  ${NOT_ALLOWED_RESET_BBMOD_LIST}

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

Get all BTS BBMOD CELL mapping based on BBPOOL info

    FOR  ${alias}  IN  @{alias_list}

        ${BBMOD_id_CELL_id_dict}  ${EMPTY}=  Get BBMOD CELL mapping based on BBPOOL info from SCF  ${alias}
        Set Test Variable  ${${alias}_BBMOD_id_CELL_id_dict}  ${BBMOD_id_CELL_id_dict}

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

    END

Get all BTS Modules SN ID mapping

    FOR  ${alias}  IN  @{alias_list}

        ${MODULE_sn_id_mapping_dict}=  Get All Modules SN ID mapping  ${alias}
        Set Test Variable  ${${alias}_MODULE_sn_id_mapping_dict}  ${MODULE_sn_id_mapping_dict}

    END

Perform BBMOD Reset on BTS
    [Arguments]  ${alias}  ${CYCLE}

    ${BBMOD_count}=  Get Length  ${${alias}_BBMOD_id_list}
    Run Keyword If  ${BBMOD_count} == 0  Run Keywords
    ...  Log  Test execution will be skipped on BTS ${alias} due to no configured BBMODs on it!  console=True
    ...  AND  Return From Keyword

    FOR  ${BBMOD_id}  IN  @{${alias}_BBMOD_id_list}

        ${BBMOD_param}=  Get Parameters For  class_name=BBMOD  id_num=${BBMOD_id}  connection=${alias}
        ${BBMOD_prodName}=  Get From Dictionary  ${BBMOD_param}  productName
        ${BBMOD_sn}=  Get From Dictionary  ${BBMOD_param}  serialNumber

        ${BBMOD_reset_check}=  Check BBMOD reset validity  ${BBMOD_prodName}
        Run Keyword If  not ${BBMOD_reset_check}  Run Keywords
        ...  Log  Reset operation on BBMOD with SN ${BBMOD_sn} on BTS ${alias} will be skipped: BBMOD not allowed (${BBMOD_prodName})!  console=True
        ...  AND  Continue For Loop

        ${BBMOD_CELL_id_list}=  Get From Dictionary  ${${alias}_BBMOD_id_CELL_id_dict}  ${BBMOD_id}
        ${BBMOD_ABIA_reset_allowed}=  Run Keyword If  'ABIA' in '${BBMOD_prodName}'
        ...  Check BBMOD ABIA Reset  ${BBMOD_id}  ${BBMOD_CELL_id_list}  ${alias}
        ...  ELSE  Set Variable  True
        Run Keyword If  not ${BBMOD_ABIA_reset_allowed}  Run Keywords
        ...  Log  Reset operation on BBMOD with SN ${BBMOD_sn} on BTS ${alias} will be skipped: BBMOD ABIA processing multiple RAT cells!
        ...  console=True
        ...  AND  Continue For Loop

        Set shared RMOD Primary Link before BBMOD Reset operation

        Reset BBMOD  ${BBMOD_id}  ${BBMOD_sn}  ${alias}

        Check all BTS requested RMOD reset behavior based on Uptime info  ${alias}

        Check all BTS reset behavior based on IMS info  ${alias}

        Get and check KPI5 info from IMS file  ${BBMOD_id}  ${BBMOD_sn}  ${BBMOD_prodName}  ${CYCLE}  ${alias}

    END

Check BBMOD reset validity
    [Arguments]  ${BBMOD_prodName}

    ${BBMOD_reset_check}=  Set Variable  ${TRUE}

    ${NOT_ALLOWED_RESET_BBMOD_LIST_isEmpty}=  Run Keyword And Return Status  Should Be Empty  ${NOT_ALLOWED_RESET_BBMOD_LIST}

    Return From Keyword If  ${NOT_ALLOWED_RESET_BBMOD_LIST_isEmpty}  ${BBMOD_reset_check}

    FOR  ${item}  IN  @{NOT_ALLOWED_RESET_BBMOD_LIST}

        ${BBMOD_reset_check}=  Set Variable If  '${item}' in '${BBMOD_prodName}'  ${FALSE}
        Exit For Loop If  '${item}' in '${BBMOD_prodName}'

    END

    [Return]  ${BBMOD_reset_check}

Set shared RMOD Primary Link before BBMOD Reset operation
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
    ...  AND  Sleep  60s  reason=Allow RMOD uptime update in BTS after set Primary Link

Reset BBMOD
    [Arguments]  ${BBMOD_id}  ${BBMOD_sn}  ${alias}

    ${peer_alias}=  Set Variable If  '${alias}' == 'Master'  Slave  Master

    Log  ***** Perform "Reset" operation on BBMOD with SN ${BBMOD_sn} on BTS ${alias} *****  console=True

    Get all BTS impact info due to reset BBMOD  ${BBMOD_id}  ${alias}  ${peer_alias}

    ${CB010846_BBMOD_shared_RMOD_count}=  Get Length  ${CB010846_BBMOD_shared_RMOD_sn_list}

    Run Keyword If  ${CB010846_BBMOD_shared_RMOD_count} > 0  Run Keywords
    ...  Log  Get Primary Link status (linkModeSynchronization) for BBMOD shared RMODs eligible for CB010846:  console=True
    ...  AND  Get shared RMOD synchronisation info on both BTS  shared_RMOD_sn_list=${CB010846_BBMOD_shared_RMOD_sn_list}

    ${BTS_alias_RMOD_sn_Uptime_dict_initial}=  Get all BTS RMOD Uptime info
    Set Test Variable  ${BTS_alias_RMOD_sn_Uptime_dict_initial}

    ${new_alias}=  Set Variable  resetBBMOD
    Start new ADMIN instance  alias=${alias}  new_alias=${new_alias}
    Get Current Time  initial
    Get Current Date UTC info  start_resetBBMOD
    ${reset_info}=  Run Keyword In Background  Reset Unit  dist_name=${BBMOD_id}  reset_type=Warm  timeout=${BBMOD_MAX_WAIT_TIME}
    ...  connection=${new_alias}

    Check BTS states and alarms during reset BBMOD  ${BBMOD_id}  ${BBMOD_sn}  ${alias}

    Check peer BTS states and alarms during reset BBMOD  ${BBMOD_sn}  ${alias}  ${peer_alias}

    Collect Keyword Result  ${reset_info}  timeout=${BBMOD_MAX_WAIT_TIME}

    Check BTS states and alarms after reset BBMOD  ${BBMOD_id}  ${BBMOD_sn}  ${alias}

    Check all BTS state and alarm after BBMOD reset  ${BBMOD_sn}

    Sleep  60s  reason=Allow RMOD uptime update in BTS after BBMOD reset
    Get Current Date UTC info  end_resetBBMOD

    Run Keyword If  ${${peer_alias}_CB007447_status}
    ...  Check peer BTS CPRI shared RMODs status with CB007447 feature activated  ${peer_BTS_CPRI_shared_RMOD_id_list}
    ...  ${date_timestamp_start_resetBBMOD_UTC}  ${date_timestamp_end_resetBBMOD_UTC}  ${peer_alias}

    [Teardown]  Teardown Admin  alias=${new_alias}

Get all BTS impact info due to reset BBMOD
    [Arguments]  ${BBMOD_id}  ${alias}  ${peer_alias}

    ${expected_own_BTS_enabled_shared_RMOD_id_list}  ${expected_own_BTS_disabled_shared_RMOD_id_list}
    ...  ${expected_peer_BTS_enabled_shared_RMOD_sn_list}  ${expected_peer_BTS_disabled_shared_RMOD_sn_list}
    ...  ${expected_own_BTS_enabled_dedicated_RMOD_id_list}  ${expected_own_BTS_disabled_dedicated_RMOD_id_list}=
    ...  Get BTSs impact due to reset BBMOD on connected RMODs  ${BBMOD_id}  ${alias}

    ${expected_peer_BTS_enabled_shared_RMOD_id_list}=  Get peer BTS shared RMOD id list  ${expected_peer_BTS_enabled_shared_RMOD_sn_list}
    ...  ${peer_alias}
    ${expected_peer_BTS_disabled_shared_RMOD_id_list}=  Get peer BTS shared RMOD id list  ${expected_peer_BTS_disabled_shared_RMOD_sn_list}
    ...  ${peer_alias}

    ${peer_BTS_shared_RMOD_id_list}=  Combine Lists  ${expected_peer_BTS_enabled_shared_RMOD_id_list}
    ...  ${expected_peer_BTS_disabled_shared_RMOD_id_list}
    ${peer_BTS_CPRI_shared_RMOD_id_list}=  Run Keyword If  ${${peer_alias}_CB007447_status}
    ...  Get peer BTS CPRI shared RMODs  ${peer_BTS_shared_RMOD_id_list}  ${peer_alias}
    Set Test Variable  ${peer_BTS_CPRI_shared_RMOD_id_list}

    Run Keyword If  ${${peer_alias}_CB007447_status}  Run Keywords
    ...  Append To List  ${expected_peer_BTS_enabled_shared_RMOD_id_list}  @{peer_BTS_CPRI_shared_RMOD_id_list}
    ...  AND  Remove Values From List  ${expected_peer_BTS_disabled_shared_RMOD_id_list}  @{peer_BTS_CPRI_shared_RMOD_id_list}
    Remove Duplicates  ${expected_peer_BTS_enabled_shared_RMOD_id_list}
    Remove Duplicates  ${expected_peer_BTS_disabled_shared_RMOD_id_list}

    Set Test Variable  ${expected_own_BTS_enabled_shared_RMOD_id_list}
    Set Test Variable  ${expected_own_BTS_disabled_shared_RMOD_id_list}
    Set Test Variable  ${expected_peer_BTS_enabled_shared_RMOD_id_list}
    Set Test Variable  ${expected_peer_BTS_disabled_shared_RMOD_id_list}
    Set Test Variable  ${expected_own_BTS_enabled_dedicated_RMOD_id_list}
    Set Test Variable  ${expected_own_BTS_disabled_dedicated_RMOD_id_list}

    ${BBMOD_NR_CELL_id_list}  ${BBMOD_LTE_CELL_id_list}  ${BBMOD_WCDMA_CELL_id_list}  ${BBMOD_GSM_CELL_id_list}=  Get BTS cells mapped on BBMOD
    ...  ${BBMOD_id}  ${alias}
    Set Test Variable  ${BBMOD_NR_CELL_id_list}
    Set Test Variable  ${BBMOD_LTE_CELL_id_list}
    Set Test Variable  ${BBMOD_WCDMA_CELL_id_list}
    Set Test Variable  ${BBMOD_GSM_CELL_id_list}

    ${BBMOD_disabled_RMOD_id_list}=  Combine Lists  ${expected_own_BTS_disabled_shared_RMOD_id_list}
    ...  ${expected_own_BTS_disabled_dedicated_RMOD_id_list}
    ${BBMOD_disabled_RMOD_id_list}=  Remove duplicates   ${BBMOD_disabled_RMOD_id_list}
    ${BBMOD_impacted_NR_CELL_id_list}  ${BBMOD_impacted_LTE_CELL_id_list}  ${BBMOD_impacted_WCDMA_CELL_id_list}
    ...  ${BBMOD_impacted_GSM_CELL_id_list}=  Get BTS cells mapped on RMOD impact due to reset BBMOD  ${BBMOD_id}  ${BBMOD_disabled_RMOD_id_list}
    ...  ${alias}
    Set Test Variable  ${BBMOD_impacted_NR_CELL_id_list}
    Set Test Variable  ${BBMOD_impacted_LTE_CELL_id_list}
    Set Test Variable  ${BBMOD_impacted_WCDMA_CELL_id_list}
    Set Test Variable  ${BBMOD_impacted_GSM_CELL_id_list}

    ${BBMOD_shared_RMOD_id_list}=  Combine Lists  ${expected_own_BTS_enabled_shared_RMOD_id_list}
    ...  ${expected_own_BTS_disabled_shared_RMOD_id_list}
    ${BBMOD_dedicated_RMOD_id_list}=  Combine Lists  ${expected_own_BTS_enabled_dedicated_RMOD_id_list}
    ...  ${expected_own_BTS_disabled_dedicated_RMOD_id_list}
    ${CB010846_BBMOD_shared_RMOD_sn_list}  ${CB010846_BBMOD_dedicated_RMOD_sn_list}=  Get BBMOD RMOD eligible for CB010846
    ...  ${BBMOD_shared_RMOD_id_list}  ${BBMOD_dedicated_RMOD_id_list}  ${alias}
    Set Test Variable  ${CB010846_BBMOD_shared_RMOD_sn_list}
    Set Test Variable  ${CB010846_BBMOD_dedicated_RMOD_sn_list}

    ${peer_BTS_OBSAI_FID10_alarm_count}  ${peer_BTS_CPRI_FID10_1815_alarm_count}  ${peer_BTS_ECPRI_FID16_alarm_count}=  Get peer BTS alarms
    ...  ${expected_peer_BTS_disabled_shared_RMOD_id_list}  ${peer_alias}
    ${peer_SBTS_EXPECTED_ALARMS_10}=  Prepare expected alarms list  ${test_alarms_list['${peer_alias.upper()}_EXPECTED_ALARMS_10']}
    ...  ${peer_BTS_OBSAI_FID10_alarm_count}
    ${peer_SBTS_EXPECTED_ALARMS_10_1815}=  Prepare expected alarms list  ${test_alarms_list['${peer_alias.upper()}_EXPECTED_ALARMS_10_1815']}
    ...  ${peer_BTS_CPRI_FID10_1815_alarm_count}
    ${peer_SBTS_EXPECTED_ALARMS_16}=  Prepare expected alarms list  ${test_alarms_list['${peer_alias.upper()}_EXPECTED_ALARMS_16']}
    ...  ${peer_BTS_ECPRI_FID16_alarm_count}
    ${peer_SBTS_EXPECTED_ALARMS_10_1815_16}=  Combine Lists  ${peer_SBTS_EXPECTED_ALARMS_10}  ${peer_SBTS_EXPECTED_ALARMS_10_1815}
    ...  ${peer_SBTS_EXPECTED_ALARMS_16}
    Set Test Variable  ${peer_BTS_OBSAI_FID10_alarm_count}
    Set Test Variable  ${peer_BTS_CPRI_FID10_1815_alarm_count}
    Set Test Variable  ${peer_BTS_ECPRI_FID16_alarm_count}
    Set Test Variable  ${peer_SBTS_EXPECTED_ALARMS_10_1815_16}

Get BBMOD RMOD eligible for CB010846
    [Arguments]  ${BBMOD_shared_RMOD_id_list}  ${BBMOD_dedicated_RMOD_id_list}  ${alias}

    ${CB010846_BBMOD_shared_RMOD_sn_list}=  Create List
    ${CB010846_BBMOD_dedicated_RMOD_sn_list}=  Create List

    ${CB010846_shared_RMOD_sn_list}=  Get From Dictionary  ${BTS_alias_CB010846_shared_RMOD_sn_dict}  ${alias}
    FOR  ${RMOD_sn}  IN  @{CB010846_shared_RMOD_sn_list}

        ${RMOD_id}=  Get From Dictionary  ${${alias}_MODULE_sn_id_mapping_dict}  ${RMOD_sn}
        Run Keyword If  '${RMOD_id}' in ${BBMOD_shared_RMOD_id_list}
        ...  Append To List  ${CB010846_BBMOD_shared_RMOD_sn_list}  ${RMOD_sn}

    END

    ${CB010846_dedicated_RMOD_sn_list}=  Get From Dictionary  ${BTS_alias_CB010846_dedicated_RMOD_sn_dict}  ${alias}
    FOR  ${RMOD_sn}  IN  @{CB010846_dedicated_RMOD_sn_list}

        ${RMOD_id}=  Get From Dictionary  ${${alias}_MODULE_sn_id_mapping_dict}  ${RMOD_sn}
        Run Keyword If  '${RMOD_id}' in ${BBMOD_dedicated_RMOD_id_list}
        ...  Append To List  ${CB010846_BBMOD_dedicated_RMOD_sn_list}  ${RMOD_sn}

    END

    [Return]  ${CB010846_BBMOD_shared_RMOD_sn_list}  ${CB010846_BBMOD_dedicated_RMOD_sn_list}

Get shared RMOD synchronisation info on both BTS
    [Arguments]  ${shared_RMOD_sn_list}

    ${shared_RMOD_sn_BTS_alias_linkModeSynchronization_info_dict}=  Create Dictionary

     FOR  ${RMOD_sn}  IN  @{shared_RMOD_sn_list}

        ${BTS_alias_linkModeSynchronization_info_dict}  ${RMOD_interface}=  Get shared RMOD synchronisation info  ${RMOD_sn}

    END

    [Return]  ${shared_RMOD_sn_BTS_alias_linkModeSynchronization_info_dict}

Get shared RMOD synchronisation info
    [Arguments]  ${RMOD_sn}

    ${RMOD_BTS_alias_list}=  Get From Dictionary  ${RMOD_sn_BTS_alias_dict}  ${RMOD_sn}
    ${BTS_alias_linkModeSynchronization_info_dict}=  Create Dictionary

    Log  RMOD_${RMOD_sn} linkModeSynchronization info:  console=True

    FOR  ${alias}  IN  @{RMOD_BTS_alias_list}

        ${RMOD_linkModeSynchronization}  ${RMOD_interface}=  Get classical BTS RMOD synchronisation info from SCF  ${RMOD_sn}  ${alias}
        Log  - BTS ${alias} (${RMOD_interface}): ${RMOD_linkModeSynchronization}  console=True

        Set To Dictionary  ${BTS_alias_linkModeSynchronization_info_dict}  ${alias}  ${RMOD_linkModeSynchronization}

    END

    [Return]  ${BTS_alias_linkModeSynchronization_info_dict}  ${RMOD_interface}

Check BTS states and alarms during reset BBMOD
    [Arguments]  ${BBMOD_id}  ${BBMOD_sn}  ${alias}

    Log  Check BTS ${alias} state and alarms during reset BBMOD with SN ${BBMOD_sn} on BTS ${alias}:  console=True

    Log  Check BTS ${alias} BBMOD with SN ${BBMOD_sn} status:  console=True
    Assert  class_name=BBMOD  id=${BBMOD_id}  parameters=${BBMOD_state_disabled_check}  timeout=${BBMOD_MAX_WAIT_TIME}  connection=${alias}
    Log  BBMOD ${BBMOD_id} status:\n - ${BBMOD_state_disabled} as expected  console=True

    Check BTS status during reset BBMOD impact on connected RMODs  ${expected_own_BTS_enabled_shared_RMOD_id_list}
    ...  ${expected_own_BTS_disabled_shared_RMOD_id_list}  ${expected_own_BTS_enabled_dedicated_RMOD_id_list}
    ...  ${expected_own_BTS_disabled_dedicated_RMOD_id_list}  ${BBMOD_sn}  ${alias}

    Check BTS status during reset BBMOD impact on BBMOD cells   ${BBMOD_NR_CELL_id_list}  ${BBMOD_LTE_CELL_id_list}  ${BBMOD_WCDMA_CELL_id_list}
    ...  ${BBMOD_GSM_CELL_id_list}  ${BBMOD_sn}  ${alias}

    Check BTS status during reset BBMOD impact on connected RMODs cells  ${BBMOD_impacted_NR_CELL_id_list}  ${BBMOD_impacted_LTE_CELL_id_list}
    ...  ${BBMOD_impacted_WCDMA_CELL_id_list}  ${BBMOD_impacted_GSM_CELL_id_list}  ${BBMOD_sn}  ${alias}

    Log  Check BTS ${alias} alarms:  console=True
    Get and Check Alarms SOAM  alias=${alias}  expected_alarms=@{EMPTY}
    ...  ignored_alarms=${test_alarms_list['${alias.upper()}_IGNORED_ALARMS_DURING_RESET']}
    ...  critical_alarms=${test_alarms_list['${alias.upper()}_CRITICAL_ALARMS']}
    Log  BTS ${alias} site - expected, ignored and critical alarms checked  console=True

Check peer BTS states and alarms during reset BBMOD
    [Arguments]  ${BBMOD_sn}  ${alias}  ${peer_alias}

    Log  Check BTS ${peer_alias} state and alarms during reset BBMOD with SN ${BBMOD_sn} on BTS ${alias}:  console=True

    Check peer BTS status during reset BBMOD impact on connected RMODs  ${expected_peer_BTS_enabled_shared_RMOD_id_list}
    ...  ${expected_peer_BTS_disabled_shared_RMOD_id_list}  ${BBMOD_sn}  ${peer_alias}

    Log  Check BTS ${peer_alias} alarms:  console=True
    Run Keyword If  ${peer_BTS_OBSAI_FID10_alarm_count} > 0
    ...  Log  BTS ${peer_alias} "No connection to Unit (10)" alarm, expected number: ${peer_BTS_OBSAI_FID10_alarm_count}  console=True
    Run Keyword If  ${peer_BTS_CPRI_FID10_1815_alarm_count} > 0 and not ${${peer_alias}_CB007447_status}
    ...  Log Long String  BTS ${peer_alias} "Not able to synchronize baseband bus (1815)" or "No connection to unit (10)" alarm, expected number:
    ...  ${peer_BTS_CPRI_FID10_1815_alarm_count}  console=True
    Run Keyword If  ${peer_BTS_ECPRI_FID16_alarm_count} > 0
    ...  Log  BTS ${peer_alias} "Unit synchronization failed (16)" alarm, expected number: ${peer_BTS_ECPRI_FID16_alarm_count}  console=True

    Get and Check Alarms SOAM  alias=${peer_alias}  poll_interval=3  expected_alarms=${peer_SBTS_EXPECTED_ALARMS_10_1815_16}
    ...  ignored_alarms=${test_alarms_list['${peer_alias.upper()}_IGNORED_ALARMS_DURING_RESET']}
    ...  critical_alarms=${test_alarms_list['${peer_alias.upper()}_CRITICAL_ALARMS']}

    Run Keyword If  ${peer_BTS_OBSAI_FID10_alarm_count} > 0
    ...  Log  BTS ${peer_alias} "No connection to Unit (10)" alarm, found number: ${peer_BTS_OBSAI_FID10_alarm_count}, as expected!  console=True
    Run Keyword If  ${peer_BTS_CPRI_FID10_1815_alarm_count} > 0 and not ${${peer_alias}_CB007447_status}
    ...  Log Long String  BTS ${peer_alias} "Not able to synchronize baseband bus (1815)" or "No connection to unit (10)" alarm, found number:
    ...  ${peer_BTS_CPRI_FID10_1815_alarm_count}, as expected!  console=True
    Run Keyword If  ${peer_BTS_ECPRI_FID16_alarm_count} > 0
    ...  Log  BTS ${peer_alias} "Unit synchronization failed (16)" alarm, found number: ${peer_BTS_ECPRI_FID16_alarm_count}, as expected!
    ...  console=True

Check BTS states and alarms after reset BBMOD
    [Arguments]  ${BBMOD_id}  ${BBMOD_sn}  ${alias}

    Log  Check BTS ${alias} state and alarms after reset BBMOD with SN ${BBMOD_sn} on BTS ${alias}:  console=True

    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_initial}  ${BBMOD_MAX_WAIT_TIME}
    Log  Check BTS ${alias} BBMOD with SN ${BBMOD_sn} status:  console=True
    Assert  class_name=BBMOD  id=${BBMOD_id}  parameters=${BBMOD_state_enabled_check}  timeout=${remained_MAX_WAIT_TIME}  connection=${alias}
    Log  BBMOD ${BBMOD_id} status:\n - ${BBMOD_state_enabled} as expected  console=True

    ${BBMOD_RMOD_id_list}=  Combine Lists  ${expected_own_BTS_enabled_shared_RMOD_id_list}  ${expected_own_BTS_disabled_shared_RMOD_id_list}
    ...  ${expected_own_BTS_enabled_dedicated_RMOD_id_list}  ${expected_own_BTS_disabled_dedicated_RMOD_id_list}
    ${BBMOD_RMOD_id_list}=  Remove Duplicates  ${BBMOD_RMOD_id_list}
    Sort List  ${BBMOD_RMOD_id_list}
    Check BTS status after reset BBMOD impact on connected RMODs  ${BBMOD_RMOD_id_list}  ${BBMOD_sn}  ${alias}

    Log  Check BTS ${alias} cells status:  console=True
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_initial}  ${BBMOD_MAX_WAIT_TIME}
    Check cells availability status online  ${alias}  ${remained_MAX_WAIT_TIME}
    Log  All BTS ${alias} cells status:\n - ${CELL_state_enabled}  console=True

    Log  Check BTS ${alias} alarms:  console=True
    Get and Check Alarms SOAM  alias=${alias}  expected_alarms=@{EMPTY}  ignored_alarms=${test_alarms_list['${alias.upper()}_IGNORED_ALARMS']}
    ...  critical_alarms=${test_alarms_list['${alias.upper()}_CRITICAL_ALARMS']}
    Log  BTS ${alias} site - expected, ignored and critical alarms checked  console=True

Check all BTS state and alarm after BBMOD reset
    [Arguments]  ${BBMOD_sn}

    FOR  ${alias}  IN  @{alias_list}

        Log  Check BTS ${alias} state and alarms after reset BBMOD with SN ${BBMOD_sn} from BTS ${alias}:  console=True

        Log  Check BTS ${alias} status  console=True
        Admin Check BTS Procedural and Blocking states  ${OnAir_}  ${Unblocked_}  ${BBMOD_MAX_WAIT_TIME}  ${alias}
        Log  BTS ${alias} status:\n - proceduralState: OnAir, blockingState: Unblocked  console=True

        Log  Check RMOD(s) status on BTS ${alias}  console=True
        Assert Every  class_name=RMOD  parameters=${RMOD_state_enabled_check}  timeout=${BBMOD_MAX_WAIT_TIME}  connection=${alias}
        Log  BTS ${alias} RMOD(s) status:\n - ${RMOD_state_enabled}  console=True

        Log  Check CELL(s) status on BTS ${alias}  console=True
        Check cells availability status online  ${alias}  ${BBMOD_MAX_WAIT_TIME}
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

        Check object parameters values are not changed from IMS file  ${ims_file_path}  ${RMOD_id}  ${RMOD_status_dict}  ${date_timestamp_start_UTC}
        ...  ${date_timestamp_end_UTC}

    END

    Log  BTS ${alias} CPRI shared RMODs status with CB007447 feature activated as expected  console=True

Check all BTS reset behavior based on IMS info
    [Documentation]
    ...  BTS RESET info is checked based on IMS info. Reset behavior as expected if no BTS reset occurs.
    ...  Otherwise, reset behavior not as expected, then errors are added to report and failed.
    [Arguments]  ${alias}

    Log  Check all BTS reset behavior based on IMS info  console=True

    Get and check BTS RESET info from IMS file  expected_reset_number=0  alias=${alias}
    ...  start_point_timestamp_UTC=${date_timestamp_start_resetBBMOD_UTC}  end_point_timestamp_UTC=${date_timestamp_end_resetBBMOD_UTC}

    FOR  ${other_alias}  IN  @{alias_list}

        Continue For Loop If  '${other_alias}' == '${alias}'

        Get and check BTS RESET info from IMS file  expected_reset_number=0  alias=${other_alias}
        ...  start_point_timestamp_UTC=${date_timestamp_start_resetBBMOD_UTC}  end_point_timestamp_UTC=${date_timestamp_end_resetBBMOD_UTC}

    END

Check all BTS requested RMOD reset behavior based on Uptime info
    [Documentation]
    ...  Shared and dedicated RMOD RESET behavior is checked based on Uptime info get from BTS. RMOD reset behavior as expected if:
    ...  - RMOD on all BTS: no reset if RU is eligible for CB010846 feature
    ...  Otherwise, reset behavior not as expected, then errors are added to report and failed.
    [Arguments]  ${alias}

    Log  Check all BTS requested RMOD reset behavior based on Uptime info  console=True

    ${BTS_alias_RMOD_sn_Uptime_dict_final}=  Get all BTS RMOD Uptime info
    Set Test Variable  ${BTS_alias_RMOD_sn_Uptime_dict_final}

    Log  Check BTS ${alias} BBMOD shared RMOD eligible for CB010846 feature reset behavior based on Uptime info  console=True

    ${CB010846_BBMOD_shared_RMOD_count}=  Get Length  ${CB010846_BBMOD_shared_RMOD_sn_list}

    Run Keyword If  ${CB010846_BBMOD_shared_RMOD_count} > 0
    ...  Check RMOD reset behavior on BTS  RMOD_sn_list=${CB010846_BBMOD_shared_RMOD_sn_list}  alias=${alias}
    ...  ELSE
    ...  Log  No BBMOD shared RMODs eligible for CB010846 feature on BTS ${alias}  console=True

    Log  Check BTS ${alias} BBMOD dedicated RMOD eligible for CB010846 feature reset behavior based on Uptime info  console=True

    ${CB010846_BBMOD_dedicated_RMOD_count}=  Get Length  ${CB010846_BBMOD_dedicated_RMOD_sn_list}

    Run Keyword If  ${CB010846_BBMOD_dedicated_RMOD_count} > 0
    ...  Check RMOD reset behavior on BTS  RMOD_sn_list=${CB010846_BBMOD_dedicated_RMOD_sn_list}  alias=${alias}
    ...  ELSE
    ...  Log  No BBMOD dedicated RMODs eligible for CB010846 feature on BTS ${alias}  console=True

    FOR  ${other_alias}  IN  @{alias_list}

        Continue For Loop If  '${other_alias}' == '${alias}'

        Log  Check BTS ${other_alias} shared RMODs eligible for CB010846 feature reset behavior based on Uptime info  console=True

        ${BTS_peer_CB010846_BBMOD_shared_RMOD_sn_list}=  Get peer BTS shared RMOD  ${CB010846_BBMOD_shared_RMOD_sn_list}  ${other_alias}
        ${BTS_peer_CB010846_shared_RMOD_sn_count}=  Get Length  ${BTS_peer_CB010846_BBMOD_shared_RMOD_sn_list}

        ${BTS_peer_CB010846_BBMOD_shared_RMOD_sn_count}=  Get Length  ${BTS_peer_CB010846_BBMOD_shared_RMOD_sn_list}

        Run Keyword If  ${BTS_peer_CB010846_BBMOD_shared_RMOD_sn_count} > 0
        ...  Check RMOD reset behavior on BTS  RMOD_sn_list=${BTS_peer_CB010846_BBMOD_shared_RMOD_sn_list}  alias=${other_alias}
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

    Run Keyword If  ${CB010846_BBMOD_shared_RMOD_count} > 0  Run Keywords
    ...  Log  Get Primary Link status (linkModeSynchronization) for BBMOD shared RMODs eligible for CB010846:  console=True
    ...  AND  Get shared RMOD synchronisation info on both BTS  shared_RMOD_sn_list=${CB010846_BBMOD_shared_RMOD_sn_list}

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

Get and check KPI5 info from IMS file
    [Documentation]
    ...  Get and check KPI5 info from IMS file.

    [Arguments]  ${BBMOD_id}  ${BBMOD_sn}  ${BBMOD_prodName}  ${CYCLE}  ${alias}

    Log  Get and check KPI5 info from IMS file on BTS ${alias} for iteration ${CYCLE}  console=True

    ${BBMOD_CELL_id_list}=  Get From Dictionary  ${${alias}_BBMOD_id_CELL_id_dict}  ${BBMOD_id}
    ${BBMOD_CELL_id_count}=  Get Length  ${BBMOD_CELL_id_list}
    Run Keyword If  ${BBMOD_CELL_id_count} == 0  Run Keywords
    ...  Log  KPI5 calculation and reporting will be skipped because BBMOD with SN ${BBMOD_sn} does not process any cells  console=True
    ...  AND  Return From Keyword

    ${kpi_name_delta_dict_kpi5}=  Get and check KPI info from IMS file
    ...  kpi_names=kpi5  kpi_thresholds=${BBMOD_RESET_WRN_THR}  alias=${alias}  start_point_timestamp_UTC=${date_timestamp_start_resetBBMOD_UTC}
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

        Run Keyword If  '${item}' in ${${alias}_NR_CELL_id_list}
        ...  Append To List  ${BBMOD_NR_CELL_id_list}  ${item}
        ...  ELSE IF  '${item}' in ${${alias}_LTE_CELL_id_list}
        ...  Append To List  ${BBMOD_LTE_CELL_id_list}  ${item}
        ...  ELSE IF  '${item}' in ${${alias}_WCDMA_CELL_id_list}
        ...  Append To List  ${BBMOD_WCDMA_CELL_id_list}  ${item}
        ...  ELSE IF  '${item}' in ${${alias}_GSM_CELL_id_list}
        ...  Append To List  ${BBMOD_GSM_CELL_id_list}  ${item}

    END

    [Return]  ${BBMOD_NR_CELL_id_list}  ${BBMOD_LTE_CELL_id_list}  ${BBMOD_WCDMA_CELL_id_list}  ${BBMOD_GSM_CELL_id_list}

Get BTS cells mapped on RMOD impact due to reset BBMOD
    [Arguments]  ${BBMOD_id}  ${BBMOD_disabled_RMOD_id_list}  ${alias}

    ${BBMOD_impacted_NR_CELL_id_list}=  Create List
    ${BBMOD_impacted_LTE_CELL_id_list}=  Create List
    ${BBMOD_impacted_WCDMA_CELL_id_list}=  Create List
    ${BBMOD_impacted_GSM_CELL_id_list}=  Create List
    ${BBMOD_disabled_RMOD_CELL_id_list}=  Create List

    ${BBMOD_CELL_id_list}=  Get From Dictionary  ${${alias}_BBMOD_id_CELL_id_dict}  ${BBMOD_id}

    FOR  ${item}  IN  @{BBMOD_disabled_RMOD_id_list}

        ${CELL_id_list}=  Get Cell Mapping By Module Id  module_id=${item}  connection=${alias}
        Append To List  ${BBMOD_disabled_RMOD_CELL_id_list}  @{CELL_id_list}

    END

    ${BBMOD_disabled_RMOD_CELL_id_list}=  Remove Duplicates  ${BBMOD_disabled_RMOD_CELL_id_list}
    Sort List  ${BBMOD_disabled_RMOD_CELL_id_list}

    FOR  ${CELL_id}  IN  @{BBMOD_disabled_RMOD_CELL_id_list}

        Run Keyword If  '${CELL_id}' in ${${alias}_NR_CELL_id_list} and '${CELL_id}' not in ${BBMOD_CELL_id_list}
        ...  Append To List  ${BBMOD_impacted_NR_CELL_id_list}  ${CELL_id}
        ...  ELSE IF  '${CELL_id}' in ${${alias}_LTE_CELL_id_list} and '${CELL_id}' not in ${BBMOD_CELL_id_list}
        ...  Append To List  ${BBMOD_impacted_LTE_CELL_id_list}  ${CELL_id}
        ...  ELSE IF  '${CELL_id}' in ${${alias}_WCDMA_CELL_id_list} and '${CELL_id}' not in ${BBMOD_CELL_id_list}
        ...  Append To List  ${BBMOD_impacted_WCDMA_CELL_id_list}  ${CELL_id}
        ...  ELSE IF  '${CELL_id}' in ${${alias}_GSM_CELL_id_list} and '${CELL_id}' not in ${BBMOD_CELL_id_list}
        ...  Append To List  ${BBMOD_impacted_GSM_CELL_id_list}  ${CELL_id}

    END

    [Return]  ${BBMOD_impacted_NR_CELL_id_list}  ${BBMOD_impacted_LTE_CELL_id_list}  ${BBMOD_impacted_WCDMA_CELL_id_list}
    ...  ${BBMOD_impacted_GSM_CELL_id_list}

Check BTS Item State
    [Arguments]  ${alias}  ${BTS_item_class}  ${BTS_item_list}  ${BTS_item_state_check}  ${BTS_item_state}  ${timeout}  ${alias}

    FOR  ${item}  IN  @{BTS_item_list}

        Assert  class_name=${BTS_item_class}  id=${item}  parameters=${BTS_item_state_check}  timeout=${timeout}  connection=${alias}
        Log  BTS ${alias} ${BTS_item_class} ${item} status:\n - ${BTS_item_state}  console=True

    END

Get peer BTS alarms
    [Arguments]  ${expected_peer_BTS_disabled_shared_RMOD_id_list}  ${alias}

    ${OBSAI_FID10_alarm_count}=  Set Variable  0
    ${CPRI_FID10_1815_alarm_count}=  Set Variable  0
    ${ECPRI_FID16_alarm_count}=  Set Variable  0

    FOR  ${RMOD_id}  IN  @{expected_peer_BTS_disabled_shared_RMOD_id_list}

        ${RMOD_param}=  Get Parameters For  class_name=RMOD  id_num=${RMOD_id}  connection=${alias}
        ${RM_EXCEPTION}=  Run Keyword And Return Status  Should Contain  ${RMOD_ECPRI_fid16_exceptions}  ${RMOD_param['productName']}

        ${OBSAI_FID10_alarm_count}=  Run Keyword If  '${RMOD_param.l3Protocol}' == 'RP301_RP1'
        ...  Evaluate  ${OBSAI_FID10_alarm_count} + 1
        ...  ELSE
        ...  Evaluate  ${OBSAI_FID10_alarm_count} + 0

        ${CPRI_FID10_1815_alarm_count}=  Run Keyword If  '${RMOD_param.l3Protocol}' == 'CPRI_RP1' and not ${${alias}_CB007447_status}
        ...  Evaluate  ${CPRI_FID10_1815_alarm_count} + 1
        ...  ELSE
        ...  Evaluate  ${CPRI_FID10_1815_alarm_count} + 0

        ${ECPRI_FID16_alarm_count}=  Run Keyword If  '${RMOD_param.l3Protocol}' == 'ECPRI_MPLANE' and '${RM_EXCEPTION}' != 'True'
        ...  Evaluate  ${ECPRI_FID16_alarm_count} + 1
        ...  ELSE
        ...  Evaluate  ${ECPRI_FID16_alarm_count} + 0

    END

    [Return]  ${OBSAI_FID10_alarm_count}  ${CPRI_FID10_1815_alarm_count}  ${ECPRI_FID16_alarm_count}

Get peer BTS CPRI shared RMODs
    [Arguments]  ${peer_BTS_shared_RMOD_id_list}  ${alias}

    ${peer_BTS_CPRI_shared_RMOD_id_list}=  Create List

    FOR  ${RMOD_id}  IN  @{peer_BTS_shared_RMOD_id_list}

        ${RMOD_param}=  Get Parameters For  class_name=RMOD  id_num=${RMOD_id}  connection=${alias}
        Continue For Loop If  '${RMOD_param.l3Protocol}' != 'CPRI_RP1'

        Append To List  ${peer_BTS_CPRI_shared_RMOD_id_list}  ${RMOD_id}

    END

    [Return]  ${peer_BTS_CPRI_shared_RMOD_id_list}

Get peer BTS shared RMOD id list
    [Arguments]  ${RMOD_sn_list}  ${alias}

    ${RMOD_id_list}=  Create List

    FOR  ${RMOD_sn}  IN  @{RMOD_sn_list}

        ${RMOD_id}=  Get From Dictionary  ${${alias}_MODULE_sn_id_mapping_dict}  ${RMOD_sn}
        Append To List  ${RMOD_id_list}  ${RMOD_id}

    END
    Sort List  ${RMOD_id_list}

    [Return]  ${RMOD_id_list}

Check BTS status during reset BBMOD impact on connected RMODs
    [Arguments]  ${expected_own_BTS_enabled_shared_RMOD_id_list}  ${expected_own_BTS_disabled_shared_RMOD_id_list}
    ...  ${expected_own_BTS_enabled_dedicated_RMOD_id_list}  ${expected_own_BTS_disabled_dedicated_RMOD_id_list}  ${BBMOD_sn}  ${alias}

    Log  Check BTS ${alias} shared RMODs connected to BBMOD with SN ${BBMOD_sn} without impact status:  console=True
    Run Keyword If  ${expected_own_BTS_enabled_shared_RMOD_id_list}  Run Keywords
    ...  Check BTS Item State  ${alias}  RMOD  ${expected_own_BTS_enabled_shared_RMOD_id_list}  ${RMOD_state_enabled_check}
    ...  ${RMOD_state_enabled}  5  ${alias}
    ...  AND  Log  All BTS ${alias} shared RMODs connected to BBMOD with SN ${BBMOD_sn} without impact status as expected  console=True
    ...  ELSE
    ...  Log  No BTS ${alias} shared RMODs connected to BBMOD with SN ${BBMOD_sn} without impact status  console=True

    Log  Check BTS ${alias} dedicated RMODs connected to BBMOD with SN ${BBMOD_sn} without impact status:  console=True
    Run Keyword If  ${expected_own_BTS_enabled_dedicated_RMOD_id_list}  Run Keywords
    ...  Check BTS Item State  ${alias}  RMOD  ${expected_own_BTS_enabled_dedicated_RMOD_id_list}  ${RMOD_state_enabled_check}
    ...  ${RMOD_state_enabled}  5  ${alias}
    ...  AND  Log  All BTS ${alias} dedicated RMODs connected to BBMOD with SN ${BBMOD_sn} without impact status as expected  console=True
    ...  ELSE
    ...  Log  No BTS ${alias} dedicated RMODs connected to BBMOD with SN ${BBMOD_sn} without impact status  console=True

    Log  Check BTS ${alias} shared RMODs connected to BBMOD with SN ${BBMOD_sn} with impact status:  console=True
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_initial}  ${BBMOD_MAX_WAIT_TIME}
    Run Keyword If  ${expected_own_BTS_disabled_shared_RMOD_id_list}  Run Keywords
    ...  Check BTS Item State  ${alias}  RMOD  ${expected_own_BTS_disabled_shared_RMOD_id_list}  ${RMOD_state_disabled_check}
    ...  ${RMOD_state_disabled}  ${remained_MAX_WAIT_TIME}  ${alias}
    ...  AND  Log  All BTS ${alias} shared RMODs connected to BBMOD with SN ${BBMOD_sn} with impact status as expected  console=True
    ...  ELSE
    ...  Log  No BTS ${alias} shared RMODs connected to BBMOD with SN ${BBMOD_sn} with impact status  console=True

    Log  Check BTS ${alias} dedicated RMODs connected to BBMOD with SN ${BBMOD_sn} with impact status:  console=True
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_initial}  ${BBMOD_MAX_WAIT_TIME}
    Run Keyword If  ${expected_own_BTS_disabled_dedicated_RMOD_id_list}  Run Keywords
    ...  Check BTS Item State  ${alias}  RMOD  ${expected_own_BTS_disabled_dedicated_RMOD_id_list}  ${RMOD_state_disabled_check}
    ...  ${RMOD_state_disabled}  ${remained_MAX_WAIT_TIME}  ${alias}
    ...  AND  Log  All BTS ${alias} dedicated RMODs connected to BBMOD with SN ${BBMOD_sn} with impact status as expected  console=True
    ...  ELSE
    ...  Log  No BTS ${alias} dedicated RMODs connected to BBMOD with SN ${BBMOD_sn} with impact status  console=True

Check BTS status during reset BBMOD impact on BBMOD cells
    [Arguments]  ${BBMOD_NR_CELL_id_list}  ${BBMOD_LTE_CELL_id_list}  ${BBMOD_WCDMA_CELL_id_list}  ${BBMOD_GSM_CELL_id_list}  ${BBMOD_sn}  ${alias}

    Log  Check BTS ${alias} cells mapped on BBMOD with SN ${BBMOD_sn} with impact status:  console=True
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_initial}  ${BBMOD_MAX_WAIT_TIME}
    Run Keyword If  ${BBMOD_NR_CELL_id_list}  Run Keywords
    ...  Check BTS Item State  ${alias}  NRCEL  ${BBMOD_NR_CELL_id_list}  ${CELL_state_disabled_check}  ${CELL_state_disabled}
    ...  ${remained_MAX_WAIT_TIME}  ${alias}
    ...  AND  Log  All BTS ${alias} NR cells mapped on BBMOD with SN ${BBMOD_sn} with impact status as expected  console=True
    ...  ELSE
    ...  Log  No BTS ${alias} NR cells mapped on BBMOD with SN ${BBMOD_sn} with impact status  console=True

    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_initial}  ${BBMOD_MAX_WAIT_TIME}
    Run Keyword If  ${BBMOD_LTE_CELL_id_list}  Run Keywords
    ...  Check BTS Item State  ${alias}  LNCEL  ${BBMOD_LTE_CELL_id_list}  ${CELL_state_disabled_check}  ${CELL_state_disabled}
    ...  ${remained_MAX_WAIT_TIME}  ${alias}
    ...  AND  Log  All BTS ${alias} LTE cells mapped on BBMOD with SN ${BBMOD_sn} with impact status as expected  console=True
    ...  ELSE
    ...  Log  No BTS ${alias} LTE cells mapped on BBMOD with SN ${BBMOD_sn} with impact status  console=True

    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_initial}  ${BBMOD_MAX_WAIT_TIME}
    Run Keyword If  ${BBMOD_WCDMA_CELL_id_list}  Run Keywords
    ...  Check BTS Item State  ${alias}  WNCEL  ${BBMOD_WCDMA_CELL_id_list}  ${CELL_state_disabled_check}  ${CELL_state_disabled}
    ...  ${remained_MAX_WAIT_TIME}  ${alias}
    ...  AND  Log  All BTS ${alias} WCDMA cells mapped on BBMOD with SN ${BBMOD_sn} with impact status as expected  console=True
    ...  ELSE
    ...  Log  No BTS ${alias} WCDMA cells mapped on BBMOD with SN ${BBMOD_sn} with impact status  console=True

    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_initial}  ${BBMOD_MAX_WAIT_TIME}
    Run Keyword If  ${BBMOD_GSM_CELL_id_list}  Run Keywords
    ...  Check BTS Item State  ${alias}  GNCEL  ${BBMOD_GSM_CELL_id_list}  ${CELL_state_disabled_check}  ${CELL_state_disabled}
    ...  ${remained_MAX_WAIT_TIME}  ${alias}
    ...  AND  Log  All BTS ${alias} GSM cells mapped on BBMOD with SN ${BBMOD_sn} with impact status as expected  console=True
    ...  ELSE
    ...  Log  No BTS ${alias} GSM cells mapped on BBMOD with SN ${BBMOD_sn} with impact status  console=True

Check BTS status during reset BBMOD impact on connected RMODs cells
    [Arguments]  ${BBMOD_impacted_NR_CELL_id_list}  ${BBMOD_impacted_LTE_CELL_id_list}  ${BBMOD_impacted_WCDMA_CELL_id_list}
    ...  ${BBMOD_impacted_GSM_CELL_id_list}  ${BBMOD_sn}  ${alias}

    Log  Check BTS ${alias} cells mapped on RMODs connected to BBMOD with SN ${BBMOD_sn} with impact status:  console=True

    Set Test Variable  ${BTS_ALARM_COUNT_MIMO}  0

    Set Test Variable  ${ALARM_COUNT_MIMO}  0
    Run Keyword If  not ${BBMOD_impacted_NR_CELL_id_list}
    ...  Log  No BTS ${alias} NR cells mapped on RMODs connected to BBMOD with SN ${BBMOD_sn} with impact status  console=True
    ${NR_cell_state_degraded_list}  ${NR_cell_state_failed_list}=  Run Keyword If  ${BBMOD_impacted_NR_CELL_id_list}
    ...  Check NR cells state and MIMO alarm  cell_list=${BBMOD_impacted_NR_CELL_id_list}  alias=${alias}
    ${BTS_ALARM_COUNT_MIMO}=  Evaluate  ${BTS_ALARM_COUNT_MIMO} + ${ALARM_COUNT_MIMO}

    Set Test Variable  ${ALARM_COUNT_MIMO}  0
    Run Keyword If  not ${BBMOD_impacted_LTE_CELL_id_list}
    ...  Log  No BTS ${alias} LTE cells mapped on RMODs connected to BBMOD with SN ${BBMOD_sn} with impact status  console=True
    ${LTE_cell_state_degraded_list}  ${LTE_cell_state_failed_list}=  Run Keyword If  ${BBMOD_impacted_LTE_CELL_id_list}
    ...  Check LTE cells state and MIMO alarm  cell_list=${BBMOD_impacted_LTE_CELL_id_list}  alias=${alias}
    ${BTS_ALARM_COUNT_MIMO}=  Evaluate  ${BTS_ALARM_COUNT_MIMO} + ${ALARM_COUNT_MIMO}

    Set Test Variable  ${ALARM_COUNT_MIMO}  0
    Run Keyword If  not ${BBMOD_impacted_WCDMA_CELL_id_list}
    ...  Log  No BTS ${alias} WCDMA cells mapped on RMODs connected to BBMOD with SN ${BBMOD_sn} with impact status  console=True
    ${WCDMA_cell_state_degraded_list}  ${WCDMA_cell_state_failed_list}=  Run Keyword If  ${BBMOD_impacted_WCDMA_CELL_id_list}
    ...  Check WCDMA cells state and MIMO alarm  cell_list=${BBMOD_impacted_WCDMA_CELL_id_list}  alias=${alias}
    ${BTS_ALARM_COUNT_MIMO}=  Evaluate  ${BTS_ALARM_COUNT_MIMO} + ${ALARM_COUNT_MIMO}

    Set Test Variable  ${ALARM_COUNT_MIMO}  0
    Run Keyword If  not ${BBMOD_impacted_GSM_CELL_id_list}
    ...  Log  No BTS ${alias} GSM cells mapped on RMODs connected to BBMOD with SN ${BBMOD_sn} with impact status  console=True
    ${GSM_cell_state_degraded_list}  ${GSM_cell_state_failed_list}=  Run Keyword If  ${BBMOD_impacted_GSM_CELL_id_list}
    ...  Check GSM cells state and MIMO alarm  cell_list=${BBMOD_impacted_GSM_CELL_id_list}  alias=${alias}
    ${BTS_ALARM_COUNT_MIMO}=  Evaluate  ${BTS_ALARM_COUNT_MIMO} + ${ALARM_COUNT_MIMO}

Check peer BTS status during reset BBMOD impact on connected RMODs
    [Arguments]  ${expected_peer_BTS_enabled_shared_RMOD_sn_list}  ${expected_peer_BTS_disabled_shared_RMOD_sn_list}  ${BBMOD_sn}  ${peer_alias}

    Log  Check BTS ${peer_alias} shared RMODs connected to BBMOD with SN ${BBMOD_sn} without impact status:  console=True
    Run Keyword If  ${expected_peer_BTS_enabled_shared_RMOD_sn_list}  Run Keywords
    ...  Check BTS Item State  BTS ${peer_alias}  RMOD  ${expected_peer_BTS_enabled_shared_RMOD_sn_list}  ${RMOD_state_enabled_check}
    ...  ${RMOD_state_enabled}  5  ${peer_alias}
    ...  AND  Log  All BTS ${peer_alias} shared RMODs connected to BBMOD with SN ${BBMOD_sn} without impact status as expected  console=True
    ...  ELSE
    ...  Log  No BTS ${peer_alias} shared RMODs connected to BBMOD with SN ${BBMOD_sn} without impact status  console=True

    Log  Check BTS ${peer_alias} shared RMODs connected to BBMOD with SN ${BBMOD_sn} with impact status:  console=True
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_initial}  ${BBMOD_MAX_WAIT_TIME}
    Run Keyword If  ${expected_peer_BTS_disabled_shared_RMOD_sn_list}  Run Keywords
    ...  Check BTS Item State  BTS ${peer_alias}  RMOD  ${expected_peer_BTS_disabled_shared_RMOD_sn_list}  ${RMOD_state_disabled_check}
    ...  ${RMOD_state_disabled}  ${remained_MAX_WAIT_TIME}  ${peer_alias}
    ...  AND  Log  All BTS ${peer_alias} shared RMODs connected to BBMOD with SN ${BBMOD_sn} with impact status as expected  console=True
    ...  ELSE
    ...  Log  No BTS ${peer_alias} shared RMODs connected to BBMOD with SN ${BBMOD_sn} with impact status  console=True

Check BTS status after reset BBMOD impact on connected RMODs
    [Arguments]  ${BBMOD_RMOD_id_list}  ${BBMOD_sn}  ${alias}

    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_initial}  ${BBMOD_MAX_WAIT_TIME}
    Run Keyword If  ${BBMOD_RMOD_id_list}  Run Keywords
    ...  Check BTS Item State  ${alias}  RMOD  ${BBMOD_RMOD_id_list}  ${RMOD_state_enabled_check}  ${RMOD_state_enabled}  ${remained_MAX_WAIT_TIME}
    ...  ${alias}
    ...  AND  Log  All BTS ${alias} RMODs connected to BBMOD with SN ${BBMOD_sn} status as expected  console=True
    ...  ELSE
    ...  Log  No BTS ${alias} RMODs connected to BBMOD with SN ${BBMOD_sn}  console=True

Recover initial settings for CB010846 feature
    [Documentation]
    ...  Keyword used to recover initial settings for CB010846 feature

    [Arguments]  ${alias}

    Log  Recover initial settings for CB010846 feature on BTS ${alias}  console=True
    ${actRuResetResiliency_initial}=  Get From Dictionary  ${${alias}_BTS_CB010846_feature_dict}  actRuResetResiliency
    Set classical BTS CB010846 feature parameter  actRuResetResiliency  ${actRuResetResiliency_initial}  ${alias}
    ${cntrldResetMplaneBreakTime_initial}=  Get From Dictionary  ${${alias}_BTS_CB010846_feature_dict}  cntrldResetMplaneBreakTime
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
