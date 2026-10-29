*** Settings ***
Documentation    TC__SBTS_SBTS__STATE__Uncontrolled_L1Soc_Reset_CB010846
Variables    tc_variables/sbts_sbts__state__uncontrolled_l1soc_reset_cb010846_alarms_definitions.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${REPEAT_COUNTER}                3       # Number of Uncontrolled L1SoC Reset operations, default value 3
${uncntrldResetMplaneBreakTime}  420     # Maximum time when Radio Unit tries to re-establish released M-plane connection to BTS after baseband HW
                                         # reset. Should be in range: 220-900 (seconds), by default 420
${BTS_PRIMARY_LINK}                      # BTS for primary link set before L1SoC reset, possible values: empty (no set required),
                                         # Master (Master set required) or Slave (Slave set required), default value: empty
${SET_PRIMARY_LINK_PROCEDURE}  LANE      # Procedure for setting BTS_PRIMARY_LINK, possible values: BTS (BTS Reset), LANE (Lock Unlock SFP LANE)
${SET_PRIMARY_LINK_TIME}       480       # Time in seconds to wait for Primary Link set on ${BTS_PRIMARY_LINK}. Time needs to be higher than
                                         # uncntrldResetMplaneBreakTime parameter, default value: 480
${ALLOWED_L1SOC_RESET_BBMOD_SN_LIST}     # BBMOD SN list allowed for Uncontrolled L1SoC Reset operation. This is an ordered list
                                         # The SNs in the list are separated by comma
                                         # Example: L1223402974 L1223402974 L1203201143
${SoC_Index_TO_BE_RESET_LIST}            # List of SoC Index from each BBMOD defined in ALLOWED_L1SOC_RESET_BBMOD_SN_LIST;
                                         # The SoC Indexes in the list are separated by comma
                                         # Each list element must match in position one-on-one ALLOWED_L1SOC_RESET_BBMOD_SN_LIST elements
                                         # Example  1, 2, 1 - correlating with the values from ALLOWED_L1SOC_RESET_BBMOD_SN_LIST example,
                                         # TC will perform L1SoC reset on BBMOD L1223402974 SoC1 and Soc2 and on BBMOD L1203201143 SoC1
${L1_PROCESS_NAME}   l1_application_rt   # Process name to be killed on BSH in order to trigger L1 SoC reset; Default value: l1_application_rt
${SoC_MAX_WAIT_TIME}         900         # Maximum time to wait for cells up after BBMOD L1SoC reset, by default 900

*** Keywords ***
TC__SBTS_SBTS__STATE__Uncontrolled_L1SoC_Reset_CB010846
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-28696
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  SBTS-SBTS test case for L1SoC reset one by one, - x times sequence.
    ...  x - value of REPEAT_COUNTER parameter (default: 3)
    ...  The main steps performed for the test are:
    ...  - check initial state and alarms for both BTS
    ...  - get and check CB010846 settings on both BTS
    ...  - get primary link settings for shared RMOD before L1SoC Reset operation on BTS
    ...  - perform BBMOD Uncontrolled L1 SoC Reset operation on BTS checking states and alarms on both BTS
    ...  - check reset behavior on all BTS based on IMS info: no BTS reset expected
    ...  - get and check KPI5 info from IMS file
    ...  Pass criteria: L1SoC reset operation work as expected; states and alarms are as expected
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...
    ...  - 04.03.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28696 -[CB010846] -
    ...  P2- New Testcases : BB Capacity board improvement in reconfiguration and recovery - Uncontrolled L1Soc Reset
    ...  - 17.11.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30185 - Adapt SBTS_SBTS__STATE__Uncontrolled_L1Soc_Reset_CB010846 with
    ...  ${actForceUnitAutoReset}' == 'false' case when CB007447 is enabled
    ...  - 27.11.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30221 - Remove ${actForceUnitAutoReset}' in tests and KWs related to CB007447
    ...

    Set Tags    CA-STATE    OWNER-vasile-valentin.stanomir@nokia.com    AUTHOR-gabriel.stanculescu@nokia.com    PHASE-QT    SW-SBTS25R2

    TC Preconditions
    Step 1: Check initial all BTS state
    Step 2: Check initial all BTS alarms
    Step 3: Check CB010846 feature settings
    Step 4: Get all BTS info for configured items
    FOR  ${INDEX}  IN RANGE  1  ${REPEAT_COUNTER} + 1
        Log  ==============================================================================  console=True
        Log  Start Cycle ${INDEX} of ${REPEAT_COUNTER}  console=True
        Log  ==============================================================================  console=True
        Step 5: Perform Uncontrolled L1 SoC reset operation on all BTS for iteration ${INDEX}
        Step 6: Clear FID6450 by BTS Snapshot collection
        Step 7: Check final all BTS state
        Step 8: Check final all BTS alarms
        Step 9: Check final number and state of Cells and RMs
    END

    [Teardown]  Particular Teardown

TC Preconditions

    ${all_BTS_BBMOD_check}=  Get all BTS BBMOD info

    Run Keyword If  not ${all_BTS_BBMOD_check}  Run Keywords
    ...  Log  TC Preconditions failed. No BBMOD found on any BTS. Test execution will be stopped!  level=ERROR
    ...  AND  Fail  TC Preconditions failed. No BBMOD found on any BTS. Test execution will be stopped!

    ${ALLOWED_L1_SOC_RESET_BBMOD_LIST_strip}=  Replace String  ${ALLOWED_L1SOC_RESET_BBMOD_SN_LIST}  ${SPACE}  ${EMPTY}
    ${ALLOWED_L1SOC_RESET_BBMOD_SN_LIST}=  Split String  ${ALLOWED_L1_SOC_RESET_BBMOD_LIST_strip}  ,

    ${SoC_Index_TO_BE_RESET_LIST_strip}=  Replace String  ${SoC_Index_TO_BE_RESET_LIST}  ${SPACE}  ${EMPTY}
    ${SoC_Index_TO_BE_RESET_LIST}=  Split String  ${SoC_Index_TO_BE_RESET_LIST_strip}  ,

    ${ALLOWED_L1SOC_RESET_BBMOD_SN_LIST_len}=  Get Length  ${ALLOWED_L1SOC_RESET_BBMOD_SN_LIST}
    ${SoC_Index_TO_BE_RESET_LIST_len}=  Get Length  ${SoC_Index_TO_BE_RESET_LIST}

    Run Keyword If    ${ALLOWED_L1SOC_RESET_BBMOD_SN_LIST_len}==0
    ...  Fail
    ...  TC Parameter check failed: ALLOWED_L1SOC_RESET_BBMOD_SN_LIST cannot be empty!

    Run Keyword If  ${ALLOWED_L1SOC_RESET_BBMOD_SN_LIST_len}!=${SoC_Index_TO_BE_RESET_LIST_len}
    ...  Fail
    ...  TC Parameter check failed: ALLOWED_L1SOC_RESET_BBMOD_SN_LIST and SoC_Index_TO_BE_RESET_LIST should have the same length!

    ${BBMOD_SN_SoC_index_mapping}=  Create Dictionary
    FOR  ${i}  IN RANGE  ${ALLOWED_L1SOC_RESET_BBMOD_SN_LIST_len}
        ${BBMOD_sn}=  Get From List  ${ALLOWED_L1SOC_RESET_BBMOD_SN_LIST}  ${i}
        ${SoC_index}=  Get From List  ${SoC_Index_TO_BE_RESET_LIST}  ${i}
        ${SN_already_in_dict}=  Run Keyword And Return Status  Dictionary Should Contain Key  ${BBMOD_SN_SoC_index_mapping}  ${BBMOD_sn}
        Run Keyword If  ${SN_already_in_dict}  Run Keywords
        ...  Append To List  ${BBMOD_SN_SoC_index_mapping["${BBMOD_sn}"]}  ${SoC_index}
        ...  AND  Continue For Loop
        ${SoC_Indexes_for_BBMOD}=    Create List    ${SoC_index}
        Set To Dictionary  ${BBMOD_SN_SoC_index_mapping}   ${BBMOD_sn}=${SoC_Indexes_for_BBMOD}
    END

    Set Test Variable  ${BBMOD_SN_SoC_index_mapping}
    ${ALLOWED_L1SOC_RESET_BBMOD_SN_LIST}=  Get Dictionary Keys   ${BBMOD_SN_SoC_index_mapping}
    Set Test Variable  ${ALLOWED_L1SOC_RESET_BBMOD_SN_LIST}

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

Step ${index}: Check CB010846 feature settings
    [Documentation]
    ...  Check CB010846 feature settings on BTS

    Log  Step ${index}: Check CB010846 feature settings  console=True

    FOR  ${alias}  IN  @{alias_list}

        Log  Check CB010846 feature settings on BTS ${alias} and set them accordingly if needed  console=True

        ${BTS_CB010846_feature_dict}=  Get BTS CB010846 feature parameters  BTS_SCF_path_file=${${alias.lower()}_scf_initial}  alias=${alias}

        Set Test Variable  ${${alias}_BTS_CB010846_feature_dict}  ${BTS_CB010846_feature_dict}

        Set classical BTS CB010846 feature parameter  actRuResetResiliency  true  ${alias}
        Set classical BTS CB010846 feature parameter  uncntrldResetMplaneBreakTime  ${uncntrldResetMplaneBreakTime}  ${alias}

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
    Set Test Variable  ${BTS_alias_RMOD_sn_RMOD_l3Protocol_dict}

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

Step ${index}: Perform Uncontrolled L1 SoC reset operation on all BTS for iteration ${CYCLE}
    Log  Step ${index}: Perform Uncontrolled L1 SoC reset operation on all BTS for iteration ${CYCLE}  console=True

    FOR  ${alias}  IN  @{alias_list}

        Perform Uncontrolled BBMOD L1SoC Reset on BTS  ${alias}

    END

Step ${index}: Clear FID6450 by BTS Snapshot collection

    Log  Step ${index}: Clear FID6450 by BTS Snapshot collection  console=True

    FOR  ${alias}  IN  @{alias_list}

        Clear FID6450 by BTS Snapshot collect  ${alias}

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

Check BBMOD L1SoC reset validity
    [Arguments]  ${BBMOD_sn}

    ${BBMOD_L1_SoC_reset_check}=  Set Variable  ${TRUE}

    FOR  ${item}  IN  @{ALLOWED_L1SOC_RESET_BBMOD_SN_LIST}

        ${BBMOD_L1_SoC_reset_check}=  Set Variable If  '${item}' in '${BBMOD_sn}'  ${TRUE}  ${FALSE}
        Exit For Loop If  '${item}' in '${BBMOD_sn}'

    END

    [Return]  ${BBMOD_L1_SoC_reset_check}

BBMOD L1SoC Reset on BTS
    [Arguments]  ${alias}  ${BBMOD_id}  ${BBMOD_sn}  ${peer_alias}  ${POWERGROUP_ports}  ${BBMOD_RMODs_ports_mapping}  ${SoC_Index}

    Get all BTS impact info due to reset L1SoC on BBMOD  ${alias}  ${peer_alias}  ${POWERGROUP_ports}  ${BBMOD_RMODs_ports_mapping}

    ${BTS_alias_RMOD_sn_Uptime_dict_initial}=  Get all BTS RMOD Uptime info
    Set Test Variable  ${BTS_alias_RMOD_sn_Uptime_dict_initial}

    Get Current Time  initial
    Get Current Date UTC info  start_resetL1SoC

    Perform uncontrolled BBMOD L1SoC reset via PID kill  ${BBMOD_id}  ${BBMOD_sn}  ${SoC_Index}  ${alias}

    Check BTS states and alarms during L1SoC reset on BBMOD  ${BBMOD_id}  ${BBMOD_sn}  ${SoC_Index}  ${alias}

    Check peer BTS states and alarms during L1SoC reset on BBMOD  ${BBMOD_sn}  ${SoC_Index}  ${alias}  ${peer_alias}

    Check BTS states and alarms after L1SoC reset on BBMOD  ${BBMOD_id}  ${BBMOD_sn}  ${SoC_Index}  ${alias}

    Check all BTS state and alarm after L1SoC reset on BBMOD  ${BBMOD_sn}  ${SoC_Index}

    Sleep  60s  reason=Allow RMOD uptime update in BTS after BBMOD reset
    Get Current Date UTC info  end_resetL1SoC

    Run Keyword If  ${${peer_alias}_CB007447_status}
    ...  Check peer BTS CPRI shared RMODs status with CB007447 feature activated  ${peer_BTS_CPRI_shared_RMOD_id_list}
    ...  ${date_timestamp_start_resetL1SoC_UTC}  ${date_timestamp_end_resetL1SoC_UTC}  ${peer_alias}

Perform Uncontrolled BBMOD L1SoC Reset on BTS
    [Arguments]  ${alias}

    ${peer_alias}=  Set Variable If  '${alias}'=='Master'  Slave  Master
    ${BBMOD_count}=  Get Length  ${${alias}_BBMOD_id_list}
    Run Keyword If  ${BBMOD_count} == 0  Run Keywords
    ...  Log  Test execution will be skipped on BTS ${alias} due to no configured BBMODs on it!  console=True
    ...  AND  Return From Keyword

    FOR  ${BBMOD_id}  IN  @{${alias}_BBMOD_id_list}

        ${BBMOD_param}=  Get Parameters For  class_name=BBMOD  id_num=${BBMOD_id}  connection=${alias}
        ${BBMOD_prodName}=  Get From Dictionary  ${BBMOD_param}  productName
        ${BBMOD_sn}=  Get From Dictionary  ${BBMOD_param}  serialNumber

        ${BBMOD_reset_check}=  Check BBMOD L1SoC reset validity    ${BBMOD_sn}
        Continue For Loop If  not ${BBMOD_reset_check}

        ${status}=  Run Keyword And Return Status  Variable Should Exist  ${${BBMOD_prodName}}
        Run Keyword If  not ${status}  Run Keywords
        ...  Log  BBMOD ${BBMOD_sn} hardware type ${BBMOD_prodName} not recognized as valid for L1SoC reset operation!    console=True
        ...  AND  Fail    BBMOD ${BBMOD_sn} hardware type ${BBMOD_prodName} not recognized as valid for L1SoC reset operation!

        ${SoC_Indexes}=  Get From Dictionary  ${BBMOD_SN_SoC_index_mapping}  ${BBMOD_sn}
        Reset each requested SoC for specific BBMOD  ${${BBMOD_prodName}}  ${SoC_Indexes}  ${alias}  ${BBMOD_id}   ${BBMOD_sn}
        ...  ${peer_alias}
    END

Reset each requested SoC for specific BBMOD
    [Arguments]    ${BBMOD_product_name}  ${SoC_Indexes}  ${alias}  ${BBMOD_id}   ${BBMOD_sn}  ${peer_alias}

    FOR  ${SoC_index}  IN  @{SoC_Indexes}
      ${POWERGROUP_ports}=  Get From Dictionary  ${BBMOD_product_name}  POWERGROUP-${SoC_index}
      Log  Resetting SoC-${SoC_index} on BBMOD ${BBMOD_sn}. Impact BBMOD ports: ${POWERGROUP_ports}  console=True

      Set shared RMOD Primary Link before BBMOD L1SoC Reset operation
      ${BBMOD_RMODs_ports_mapping}=  Get BBMOD RMOD ports mapping  ${BBMOD_sn}  ${alias}

      BBMOD L1SoC Reset on BTS  ${alias}  ${BBMOD_id}   ${BBMOD_sn}  ${peer_alias}  ${POWERGROUP_ports}  ${BBMOD_RMODs_ports_mapping}
      ...  ${SoC_index}

      Check all BTS requested RMOD reset behavior based on Uptime info  ${alias}

      Check all BTS reset behavior based on IMS info  ${alias}
    END

Get all BTS impact info due to reset L1SoC on BBMOD
    [Arguments]  ${alias}  ${peer_alias}  ${POWERGROUP_ports}  ${BBMOD_RMODs_ports_mapping}

    ${expected_own_BTS_enabled_shared_RMOD_id_list}   ${expected_own_BTS_disabled_shared_RMOD_id_list}
    ...    ${expected_peer_BTS_enabled_shared_RMOD_sn_list}  ${expected_peer_BTS_disabled_shared_RMOD_sn_list}
    ...    ${expected_own_BTS_enabled_dedicated_RMOD_id_list}    ${expected_own_BTS_disabled_dedicated_RMOD_id_list}=
    ...    Get all BTS RMOD impact info due to reset BBMOD L1SoC  ${alias}  ${peer_alias}  ${POWERGROUP_ports}  ${BBMOD_RMODs_ports_mapping}

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

    ${L1SoC_disabled_RMOD_id_list}=  Combine Lists  ${expected_own_BTS_disabled_shared_RMOD_id_list}
    ...  ${expected_own_BTS_disabled_dedicated_RMOD_id_list}
    ${L1SoC_disabled_RMOD_id_list}=  Remove duplicates   ${L1SoC_disabled_RMOD_id_list}
    ${L1SoC_impacted_NR_CELL_id_list}  ${L1SoC_impacted_LTE_CELL_id_list}  ${L1SoC_impacted_WCDMA_CELL_id_list}
    ...  ${L1SoC_impacted_GSM_CELL_id_list}=  Get BTS cells mapped on RMOD impact due to reset L1SoC on BBMOD
    ...  ${L1SoC_disabled_RMOD_id_list}  ${alias}
    Set Test Variable  ${L1SoC_impacted_NR_CELL_id_list}
    Set Test Variable  ${L1SoC_impacted_LTE_CELL_id_list}
    Set Test Variable  ${L1SoC_impacted_WCDMA_CELL_id_list}
    Set Test Variable  ${L1SoC_impacted_GSM_CELL_id_list}

    ${L1SoC_shared_RMOD_id_list}=  Combine Lists  ${expected_own_BTS_enabled_shared_RMOD_id_list}
    ...  ${expected_own_BTS_disabled_shared_RMOD_id_list}
    ${L1SoC_dedicated_RMOD_id_list}=  Combine Lists  ${expected_own_BTS_enabled_dedicated_RMOD_id_list}
    ...  ${expected_own_BTS_disabled_dedicated_RMOD_id_list}
    ${CB010846_L1SoC_shared_RMOD_sn_list}  ${CB010846_L1SoC_dedicated_RMOD_sn_list}=  Get L1SoC RMOD eligible for CB010846
    ...  ${L1SoC_shared_RMOD_id_list}  ${L1SoC_dedicated_RMOD_id_list}  ${alias}
    Set Test Variable  ${CB010846_L1SoC_shared_RMOD_sn_list}
    Set Test Variable  ${CB010846_L1SoC_dedicated_RMOD_sn_list}

    ${peer_BTS_OBSAI_FID10_alarm_count}  ${peer_BTS_CPRI_FID10_1815_alarm_count}  ${peer_BTS_ECPRI_FID16_alarm_count}=  Get peer BTS alarms
    ...  ${expected_peer_BTS_disabled_shared_RMOD_id_list}  ${peer_alias}
    ${peer_SBTS_EXPECTED_ALARMS_10}=  Prepare expected alarms list  ${${peer_alias.upper()}_EXPECTED_ALARMS_10}
    ...  ${peer_BTS_OBSAI_FID10_alarm_count}
    ${peer_SBTS_EXPECTED_ALARMS_10_1815}=  Prepare expected alarms list  ${${peer_alias.upper()}_EXPECTED_ALARMS_10_1815}
    ...  ${peer_BTS_CPRI_FID10_1815_alarm_count}
    ${peer_SBTS_EXPECTED_ALARMS_16}=  Prepare expected alarms list  ${${peer_alias.upper()}_EXPECTED_ALARMS_16}
    ...  ${peer_BTS_ECPRI_FID16_alarm_count}
    ${peer_SBTS_EXPECTED_ALARMS_10_1815_16}=  Combine Lists  ${peer_SBTS_EXPECTED_ALARMS_10}  ${peer_SBTS_EXPECTED_ALARMS_10_1815}
    ...  ${peer_SBTS_EXPECTED_ALARMS_16}
    Set Test Variable  ${peer_BTS_OBSAI_FID10_alarm_count}
    Set Test Variable  ${peer_BTS_CPRI_FID10_1815_alarm_count}
    Set Test Variable  ${peer_BTS_ECPRI_FID16_alarm_count}
    Set Test Variable  ${peer_SBTS_EXPECTED_ALARMS_10_1815_16}

Check BTS states and alarms during L1SoC reset on BBMOD
    [Arguments]  ${BBMOD_id}  ${BBMOD_sn}  ${SoC_Index}  ${alias}

    ${IGNORED_ALARMS_full}=  Combine Lists  ${${alias.upper()}_IGNORED_ALARMS_DURING_RESET}  ${${alias.upper()}_IGNORED_ALARMS_6450}

    Log  Check BTS ${alias} state and alarms during L1SoC-${SoC_Index} reset on BBMOD with SN ${BBMOD_sn} on BTS ${alias}:  console=True

    Log  Check BTS ${alias} BBMOD with SN ${BBMOD_sn} status:  console=True
    Assert  class_name=BBMOD  id=${BBMOD_id}  parameters=${BBMOD_state_enabled_check}  timeout=${SoC_MAX_WAIT_TIME}  connection=${alias}
    Log  BBMOD ${BBMOD_id} status:\n - ${BBMOD_state_enabled} as expected  console=True

    Check BTS status during L1SoC reset on BBMOD impact on connected RMODs  ${expected_own_BTS_enabled_shared_RMOD_id_list}
    ...  ${expected_own_BTS_disabled_shared_RMOD_id_list}  ${expected_own_BTS_enabled_dedicated_RMOD_id_list}
    ...  ${expected_own_BTS_disabled_dedicated_RMOD_id_list}  ${BBMOD_sn}  ${SoC_Index}  ${alias}

    Check BTS status during L1SoC reseton BBMOD impact on connected RMODs cells  ${L1SoC_impacted_NR_CELL_id_list}  ${L1SoC_impacted_LTE_CELL_id_list}
    ...  ${L1SoC_impacted_WCDMA_CELL_id_list}  ${L1SoC_impacted_GSM_CELL_id_list}  ${BBMOD_sn}  ${SoC_Index}  ${alias}

    Log  Check BTS ${alias} alarms:  console=True
    Log  BTS ${alias} "SoC autonomous reset as recovery action (2087)" alarm, expected number: 1  console=True
    Get and Check Alarms SOAM  alias=${alias}  poll_interval=5s  expected_alarms=${${alias.upper()}_EXPECTED_ALARMS_2087}
    ...  ignored_alarms=${IGNORED_ALARMS_full}  critical_alarms=${${alias.upper()}_CRITICAL_ALARMS}
    Log  BTS ${alias} "SoC autonomous reset as recovery action (2087)" alarm, found number: 1, as expected!  console=True
    Log  BTS ${alias} site - expected, ignored and critical alarms checked  console=True

Check peer BTS states and alarms during L1SoC reset on BBMOD
    [Arguments]  ${BBMOD_sn}  ${SoC_Index}  ${alias}  ${peer_alias}

    ${IGNORED_ALARMS_full}=  Combine Lists  ${${peer_alias.upper()}_IGNORED_ALARMS_DURING_RESET}  ${${peer_alias.upper()}_IGNORED_ALARMS_6450}

    Log  Check BTS ${peer_alias} state and alarms during uncontrolled L1SoC-${SoC_Index} reset on BBMOD with SN ${BBMOD_sn} on BTS ${alias}:
    ...  console=True

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
    ...  ignored_alarms=${IGNORED_ALARMS_full}  critical_alarms=${${peer_alias.upper()}_CRITICAL_ALARMS}

    Run Keyword If  ${peer_BTS_OBSAI_FID10_alarm_count} > 0
    ...  Log  BTS ${peer_alias} "No connection to Unit (10)" alarm, found number: ${peer_BTS_OBSAI_FID10_alarm_count}, as expected!  console=True
    Run Keyword If  ${peer_BTS_CPRI_FID10_1815_alarm_count} > 0 and not ${${peer_alias}_CB007447_status}
    ...  Log Long String  BTS ${peer_alias} "Not able to synchronize baseband bus (1815)" or "No connection to unit (10)" alarm, found number:
    ...  ${peer_BTS_CPRI_FID10_1815_alarm_count}, as expected!  console=True
    Run Keyword If  ${peer_BTS_ECPRI_FID16_alarm_count} > 0
    ...  Log  BTS ${peer_alias} "Unit synchronization failed (16)" alarm, found number: ${peer_BTS_ECPRI_FID16_alarm_count}, as expected!
    ...  console=True

Check BTS states and alarms after L1SoC reset on BBMOD
    [Arguments]  ${BBMOD_id}  ${BBMOD_sn}  ${SoC_Index}  ${alias}

    ${IGNORED_ALARMS_full}=  Combine Lists  ${${alias.upper()}_IGNORED_ALARMS}  ${${alias.upper()}_IGNORED_ALARMS_6450}

    Log  Check BTS ${alias} state and alarms after uncontrolled L1SoC-${SoC_Index} reset on BBMOD with SN ${BBMOD_sn} on BTS ${alias}:  console=True

    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_initial}  ${SoC_MAX_WAIT_TIME}
    Log  Check BTS ${alias} BBMOD with SN ${BBMOD_sn} status:  console=True
    Assert  class_name=BBMOD  id=${BBMOD_id}  parameters=${BBMOD_state_enabled_check}  timeout=${remained_MAX_WAIT_TIME}  connection=${alias}
    Log  BBMOD ${BBMOD_id} status:\n - ${BBMOD_state_enabled} as expected  console=True

    ${L1SoC_RMOD_id_list}=  Combine Lists  ${expected_own_BTS_enabled_shared_RMOD_id_list}  ${expected_own_BTS_disabled_shared_RMOD_id_list}
    ...  ${expected_own_BTS_enabled_dedicated_RMOD_id_list}  ${expected_own_BTS_disabled_dedicated_RMOD_id_list}
    ${L1SoC_RMOD_id_list}=  Remove Duplicates  ${L1SoC_RMOD_id_list}
    Sort List  ${L1SoC_RMOD_id_list}
    Check BTS status after reset L1SoC on BBMOD impact on connected RMODs  ${L1SoC_RMOD_id_list}  ${BBMOD_sn}  ${SoC_Index}  ${alias}

    Log  Check BTS ${alias} cells status:  console=True
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_initial}  ${SoC_MAX_WAIT_TIME}
    Check cells availability status online  ${alias}  ${remained_MAX_WAIT_TIME}
    Log  All BTS ${alias} cells status:\n - ${CELL_state_enabled}  console=True

    Log  Check BTS ${alias} alarms:  console=True
    Get and Check Alarms SOAM  alias=${alias}  expected_alarms=@{EMPTY}  ignored_alarms=${IGNORED_ALARMS_full}
    ...  critical_alarms=${${alias.upper()}_CRITICAL_ALARMS}
    Log  BTS ${alias} site - expected, ignored and critical alarms checked  console=True

Check all BTS state and alarm after L1SoC reset on BBMOD
    [Arguments]  ${BBMOD_sn}  ${SoC_Index}

    FOR  ${alias}  IN  @{alias_list}

        ${IGNORED_ALARMS_full}=  Combine Lists  ${${alias.upper()}_IGNORED_ALARMS}  ${${alias.upper()}_IGNORED_ALARMS_6450}

        Log  Check BTS ${alias} state and alarms after uncontrolled reset of L1SoC-${SoC_Index} on BBMOD with SN ${BBMOD_sn} from BTS ${alias}:
        ...  console=True

        Log  Check BTS ${alias} status  console=True
        Admin Check BTS Procedural and Blocking states  ${OnAir_}  ${Unblocked_}  ${SoC_MAX_WAIT_TIME}  ${alias}
        Log  BTS ${alias} status:\n - proceduralState: OnAir, blockingState: Unblocked  console=True

        Log  Check RMOD(s) status on BTS ${alias}  console=True
        Assert Every  class_name=RMOD  parameters=${RMOD_state_enabled_check}  timeout=${SoC_MAX_WAIT_TIME}  connection=${alias}
        Log  BTS ${alias} RMOD(s) status:\n - ${RMOD_state_enabled}  console=True

        Log  Check CELL(s) status on BTS ${alias}  console=True
        Check cells availability status online  ${alias}  ${SoC_MAX_WAIT_TIME}
        Log  BTS ${alias} cells status:\n - ${CELL_state_enabled}  console=True

        Log  Check alarms on BTS ${alias}  console=True
        Get and Check Alarms SOAM  alias=${alias}  expected_alarms=@{EMPTY}  ignored_alarms=${IGNORED_ALARMS_full}
        ...  critical_alarms=${${alias.upper()}_CRITICAL_ALARMS}
        Log  BTS ${alias} site - expected, ignored and critical alarms checked  console=True

    END

Check BTS status during L1SoC reset on BBMOD impact on connected RMODs
    [Arguments]  ${expected_own_BTS_enabled_shared_RMOD_id_list}  ${expected_own_BTS_disabled_shared_RMOD_id_list}
    ...  ${expected_own_BTS_enabled_dedicated_RMOD_id_list}  ${expected_own_BTS_disabled_dedicated_RMOD_id_list}  ${BBMOD_sn}  ${SoCIndex}  ${alias}

    Log  Check BTS ${alias} shared RMODs connected to SoC-${SoCIndex} of BBMOD with SN ${BBMOD_sn} without impact status:  console=True
    Run Keyword If  ${expected_own_BTS_enabled_shared_RMOD_id_list}  Run Keywords
    ...  Check BTS Item State  ${alias}  RMOD  ${expected_own_BTS_enabled_shared_RMOD_id_list}  ${RMOD_state_enabled_check}
    ...  ${RMOD_state_enabled}  5  True
    ...  AND  Log  All BTS ${alias} shared RMODs connected to SoC-${SoCIndex} of BBMOD with SN ${BBMOD_sn} without impact status as expected
    ...  console=True
    ...  ELSE  Log  No BTS ${alias} shared RMODs connected to SoC-${SoCIndex} of BBMOD with SN ${BBMOD_sn} without impact  console=True

    Log  Check BTS ${alias} dedicated RMODs connected to SoC-${SoCIndex} of BBMOD with SN ${BBMOD_sn} without impact status:  console=True
    Run Keyword If  ${expected_own_BTS_enabled_dedicated_RMOD_id_list}  Run Keywords
    ...  Check BTS Item State  ${alias}  RMOD  ${expected_own_BTS_enabled_dedicated_RMOD_id_list}  ${RMOD_state_enabled_check}
    ...  ${RMOD_state_enabled}  5  True
    ...  AND  Log  All BTS ${alias} dedicated RMODs connected to SoC-${SoCIndex} of BBMOD with SN ${BBMOD_sn} without impact status as expected
    ...  console=True
    ...  ELSE  Log  No BTS ${alias} dedicated RMODs connected to SoC-${SoCIndex} of BBMOD with SN ${BBMOD_sn} without impact  console=True

    Log  Check BTS ${alias} shared RMODs connected to SoC-${SoCIndex} of BBMOD with SN ${BBMOD_sn} with impact status:  console=True
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_initial}  ${SoC_MAX_WAIT_TIME}
    Run Keyword If  ${expected_own_BTS_disabled_shared_RMOD_id_list}  Run Keywords
    ...  Check BTS Item State  ${alias}  RMOD  ${expected_own_BTS_disabled_shared_RMOD_id_list}  ${RMOD_state_disabled_check}
    ...  ${RMOD_state_disabled}  ${remained_MAX_WAIT_TIME}
    ...  AND  Log  All BTS ${alias} shared RMODs connected to SoC-${SoCIndex} of BBMOD with SN ${BBMOD_sn} with impact status as expected
    ...  console=True
    ...  ELSE  Log  No BTS ${alias} shared RMODs connected to SoC-${SoCIndex} of BBMOD with SN ${BBMOD_sn} with impact  console=True

    Log  Check BTS ${alias} dedicated RMODs connected to SoC-${SoCIndex} of BBMOD with SN ${BBMOD_sn} with impact status:  console=True
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_initial}  ${SoC_MAX_WAIT_TIME}
    Run Keyword If  ${expected_own_BTS_disabled_dedicated_RMOD_id_list}  Run Keywords
    ...  Check BTS Item State  ${alias}  RMOD  ${expected_own_BTS_disabled_dedicated_RMOD_id_list}  ${RMOD_state_disabled_check}
    ...  ${RMOD_state_disabled}  ${remained_MAX_WAIT_TIME}
    ...  AND  Log  All BTS ${alias} dedicated RMODs connected to SoC-${SoCIndex} of BBMOD with SN ${BBMOD_sn} with impact status as expected
    ...  console=True
    ...  ELSE  Log  No BTS ${alias} dedicated RMODs connected to SoC-${SoCIndex} of BBMOD with SN ${BBMOD_sn} with impact  console=True

Check BTS status during L1SoC reset on BBMOD impact on connected RMODs cells
    [Arguments]  ${L1SoC_impacted_NR_CELL_id_list}  ${L1SoC_impacted_LTE_CELL_id_list}  ${L1SoC_impacted_WCDMA_CELL_id_list}
    ...  ${L1SoC_impacted_GSM_CELL_id_list}  ${BBMOD_sn}  ${SoC_index}  ${alias}

    Log  Check BTS ${alias} cells mapped on RMODs connected to SoC-${SoC_index} of BBMOD with SN ${BBMOD_sn} with impact status:  console=True

    Set Test Variable  ${BTS_ALARM_COUNT_MIMO}  0

    Set Test Variable  ${ALARM_COUNT_MIMO}  0
    Run Keyword If  not ${L1SoC_impacted_NR_CELL_id_list}
    ...  Log  No BTS ${alias} NR cells mapped on RMODs connected to SoC-${SoC_index} of BBMOD with SN ${BBMOD_sn} with impact  console=True
    ${NR_cell_state_degraded_list}  ${NR_cell_state_failed_list}=  Run Keyword If  ${L1SoC_impacted_NR_CELL_id_list}
    ...  Check NR cells state and MIMO alarm  cell_list=${L1SoC_impacted_NR_CELL_id_list}  alias=${alias}
    ${BTS_ALARM_COUNT_MIMO}=  Evaluate  ${BTS_ALARM_COUNT_MIMO} + ${ALARM_COUNT_MIMO}

    Set Test Variable  ${ALARM_COUNT_MIMO}  0
    Run Keyword If  not ${L1SoC_impacted_LTE_CELL_id_list}
    ...  Log  No BTS ${alias} LTE cells mapped on RMODs connected to SoC-${SoC_index} of BBMOD with SN ${BBMOD_sn} with impact  console=True
    ${LTE_cell_state_degraded_list}  ${LTE_cell_state_failed_list}=  Run Keyword If  ${L1SoC_impacted_LTE_CELL_id_list}
    ...  Check LTE cells state and MIMO alarm  cell_list=${L1SoC_impacted_LTE_CELL_id_list}  alias=${alias}
    ${BTS_ALARM_COUNT_MIMO}=  Evaluate  ${BTS_ALARM_COUNT_MIMO} + ${ALARM_COUNT_MIMO}

    Set Test Variable  ${ALARM_COUNT_MIMO}  0
    Run Keyword If  not ${L1SoC_impacted_WCDMA_CELL_id_list}
    ...  Log  No BTS ${alias} WCDMA cells mapped on RMODs connected to SoC-${SoC_index} of BBMOD with SN ${BBMOD_sn} with impact  console=True
    ${WCDMA_cell_state_degraded_list}  ${WCDMA_cell_state_failed_list}=  Run Keyword If  ${L1SoC_impacted_WCDMA_CELL_id_list}
    ...  Check WCDMA cells state and MIMO alarm  cell_list=${L1SoC_impacted_WCDMA_CELL_id_list}  alias=${alias}
    ${BTS_ALARM_COUNT_MIMO}=  Evaluate  ${BTS_ALARM_COUNT_MIMO} + ${ALARM_COUNT_MIMO}

    Set Test Variable  ${ALARM_COUNT_MIMO}  0
    Run Keyword If  not ${L1SoC_impacted_GSM_CELL_id_list}
    ...  Log  No BTS ${alias} GSM cells mapped on RMODs connected to SoC-${SoC_index} of BBMOD with SN ${BBMOD_sn} with impact  console=True
    ${GSM_cell_state_degraded_list}  ${GSM_cell_state_failed_list}=  Run Keyword If  ${L1SoC_impacted_GSM_CELL_id_list}
    ...  Check GSM cells state and MIMO alarm  cell_list=${L1SoC_impacted_GSM_CELL_id_list}  alias=${alias}
    ${BTS_ALARM_COUNT_MIMO}=  Evaluate  ${BTS_ALARM_COUNT_MIMO} + ${ALARM_COUNT_MIMO}

Check peer BTS status during reset BBMOD impact on connected RMODs
    [Arguments]  ${expected_peer_BTS_enabled_shared_RMOD_sn_list}  ${expected_peer_BTS_disabled_shared_RMOD_sn_list}  ${BBMOD_sn}  ${peer_alias}

    Log  Check BTS ${peer_alias} shared RMODs connected to BBMOD with SN ${BBMOD_sn} without impact status:  console=True
    Run Keyword If  ${expected_peer_BTS_enabled_shared_RMOD_sn_list}  Run Keywords
    ...  Check BTS Item State  ${peer_alias}  RMOD  ${expected_peer_BTS_enabled_shared_RMOD_sn_list}  ${RMOD_state_enabled_check}
    ...  ${RMOD_state_enabled}  5  True
    ...  AND  Log  All BTS ${peer_alias} shared RMODs connected to BBMOD with SN ${BBMOD_sn} without impact status as expected  console=True
    ...  ELSE
    ...  Log  No BTS ${peer_alias} shared RMODs connected to BBMOD with SN ${BBMOD_sn} without impact  console=True

    Log  Check BTS ${peer_alias} shared RMODs connected to BBMOD with SN ${BBMOD_sn} with impact status:  console=True
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_initial}  ${SoC_MAX_WAIT_TIME}
    Run Keyword If  ${expected_peer_BTS_disabled_shared_RMOD_sn_list}  Run Keywords
    ...  Check BTS Item State  ${peer_alias}  RMOD  ${expected_peer_BTS_disabled_shared_RMOD_sn_list}  ${RMOD_state_disabled_check}
    ...  ${RMOD_state_disabled}  ${remained_MAX_WAIT_TIME}
    ...  AND  Log  All BTS ${peer_alias} shared RMODs connected to BBMOD with SN ${BBMOD_sn} with impact status as expected  console=True
    ...  ELSE
    ...  Log  No BTS ${peer_alias} shared RMODs connected to BBMOD with SN ${BBMOD_sn} with impact  console=True

Check BTS status after reset L1SoC on BBMOD impact on connected RMODs
    [Arguments]  ${L1SoC_RMOD_id_list}  ${BBMOD_sn}  ${SoC_index}  ${alias}

    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_initial}  ${SoC_MAX_WAIT_TIME}
    Run Keyword If  ${L1SoC_RMOD_id_list}  Run Keywords
    ...  Check BTS Item State  ${alias}  RMOD  ${L1SoC_RMOD_id_list}  ${RMOD_state_enabled_check}  ${RMOD_state_enabled}  ${remained_MAX_WAIT_TIME}
    ...  AND  Log  All BTS ${alias} RMODs connected to L1SoC-${SoC_index} on BBMOD with SN ${BBMOD_sn} status as expected  console=True
    ...  ELSE
    ...  Log  No BTS ${alias} RMODs connected to SoC-${SoC_index} on BBMOD with SN ${BBMOD_sn}  console=True

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

Get all BTS RMOD impact info due to reset BBMOD L1SoC
    [Arguments]    ${alias}  ${peer_alias}  ${POWERGROUP_ports}  ${BBMOD_RMODs_ports_mapping}

    ${expected_own_BTS_enabled_shared_RMOD_id_list}=  Create List
    ${expected_own_BTS_disabled_shared_RMOD_id_list}=  Create List
    ${expected_peer_BTS_enabled_shared_RMOD_sn_list}=  Create List
    ${expected_peer_BTS_disabled_shared_RMOD_sn_list}=  Create List
    ${expected_own_BTS_enabled_dedicated_RMOD_id_list}=  Create List
    ${expected_own_BTS_disabled_dedicated_RMOD_id_list}=  Create List
    FOR  ${item}  IN  @{BBMOD_RMODs_ports_mapping}
        ${RMOD_id}=  Get From Dictionary  ${${alias}_MODULE_sn_id_mapping_dict}  ${item}
        ${RMOD_sn_RMOD_l3Protocol_dict}=  Get From Dictionary  ${BTS_alias_RMOD_sn_RMOD_l3Protocol_dict}  ${alias}
        ${RMOD_L3_protocol}=   Get From Dictionary  ${RMOD_sn_RMOD_l3Protocol_dict}  ${item}
        ${port_label_lst}=  Get From Dictionary  ${BBMOD_RMODs_ports_mapping}  ${item}
        ${port_label_PL_info_dct}=  Get From List  ${port_label_lst}  0
        ${port_label_CFG_dct}=  Get From List  ${port_label_lst}  2
        Continue For Loop If  not ${port_label_PL_info_dct}
        ${PL_impact_on_RMOD}  ${CFG_impact_on_RMOD}=
        ...  Check POWERGROUP own BTS synchronization and configuration impact  ${port_label_PL_info_dct}  ${port_label_CFG_dct}  ${POWERGROUP_ports}
        ${POWERGROUP_impact_on_RMOD}=  Set Variable If  ${PL_impact_on_RMOD} or ${CFG_impact_on_RMOD}   ${True}  ${False}
        ${BTS_own_shared_RMOD_sn_list}=  Get From Dictionary  ${BTS_alias_shared_RMOD_sn_dict}  ${alias}
        ${BTS_own_dedicated_RMOD_sn_list}=  Get From Dictionary  ${BTS_alias_dedicated_RMOD_sn_dict}  ${alias}
        ${BTS_peer_shared_RMOD_sn_list}=  Get From Dictionary  ${BTS_alias_shared_RMOD_sn_dict}  ${peer_alias}
        ${BTS_peer_dedicated_RMOD_sn_list}=  Get From Dictionary  ${BTS_alias_dedicated_RMOD_sn_dict}  ${peer_alias}
        Run Keyword If  (not ${POWERGROUP_impact_on_RMOD}) and ('${item}' in ${BTS_own_shared_RMOD_sn_list})
        ...  Append To List  ${expected_own_BTS_enabled_shared_RMOD_id_list}  ${RMOD_id}
        Run Keyword If  (not ${POWERGROUP_impact_on_RMOD}) and ('${item}' in ${BTS_own_dedicated_RMOD_sn_list})
        ...  Append To List  ${expected_own_BTS_enabled_dedicated_RMOD_id_list}  ${RMOD_id}
        Run Keyword If  ${POWERGROUP_impact_on_RMOD} and ('${item}' in ${BTS_own_shared_RMOD_sn_list})
        ...  Append To List  ${expected_own_BTS_disabled_shared_RMOD_id_list}  ${RMOD_id}
        Run Keyword If  ${POWERGROUP_impact_on_RMOD} and ('${item}' in ${BTS_own_dedicated_RMOD_sn_list})
        ...  Append To List  ${expected_own_BTS_disabled_dedicated_RMOD_id_list}  ${RMOD_id}
        Continue For Loop If  '${item}' in ${BTS_own_dedicated_RMOD_sn_list}
        Run Keyword If  not ${POWERGROUP_impact_on_RMOD}  Run Keywords
        ...  Append To List  ${expected_peer_BTS_enabled_shared_RMOD_sn_list}  ${item}
        ...  AND  Continue For Loop
        Run Keyword If  ${POWERGROUP_impact_on_RMOD} and not ${PL_impact_on_RMOD}  Run Keywords
        ...  Append To List  ${expected_peer_BTS_enabled_shared_RMOD_sn_list}  ${item}
        ...  AND  Continue For Loop
        Run Keyword If  '${RMOD_L3_protocol}'=='CPRI_RP1' and ${${peer_alias}_CB007447_status}
        ...  Append To List  ${expected_peer_BTS_enabled_shared_RMOD_sn_list}  ${item}
        ...  ELSE  Append To List  ${expected_peer_BTS_disabled_shared_RMOD_sn_list}  ${item}
    END

    [Return]   ${expected_own_BTS_enabled_shared_RMOD_id_list}   ${expected_own_BTS_disabled_shared_RMOD_id_list}
    ...  ${expected_peer_BTS_enabled_shared_RMOD_sn_list}  ${expected_peer_BTS_disabled_shared_RMOD_sn_list}
    ...    ${expected_own_BTS_enabled_dedicated_RMOD_id_list}  ${expected_own_BTS_disabled_dedicated_RMOD_id_list}

Check POWERGROUP own BTS synchronization and configuration impact
    [Arguments]    ${port_label_PL_info_dct}  ${port_label_CFG_dct}  ${POWERGROUP_ports}

    ${PL_impact_on_RMOD}=  Set Variable  ${False}
    ${CFG_impact_on_RMOD}=  Set Variable  ${False}

    FOR  ${port_label}  IN  @{port_label_PL_info_dct}
        ${port_transports_PL}=  Get From Dictionary  ${port_label_PL_info_dct}  ${port_label}
        ${port_number}=  Fetch From Right  ${port_label}  RF
        Continue For Loop If  ${port_number} not in ${POWERGROUP_ports}
        ${PL_impact_on_RMOD}=  Set Variable If  ${port_transports_PL}  ${True}  ${PL_impact_on_RMOD}
    END

    FOR  ${port_label}  IN  @{port_label_CFG_dct}
        ${port_transports_CFG}=  Get From Dictionary  ${port_label_CFG_dct}  ${port_label}
        ${port_number}=  Fetch From Right  ${port_label}  RF
        Continue For Loop If  ${port_number} not in ${POWERGROUP_ports}
        ${CFG_impact_on_RMOD}=  Set Variable If  ${port_transports_CFG}  ${True}  ${CFG_impact_on_RMOD}
    END

    [Return]  ${PL_impact_on_RMOD}  ${CFG_impact_on_RMOD}

Set BBPool Tech Impacted cells dn dict
    [Arguments]    ${lcr_id_impacted_cells_list}    ${CELL_lcrId_dn_dict}
    ${impacted_cell_dn_list}=    Create List
    FOR    ${lcr_id_impacted_cell}    IN    @{lcr_id_impacted_cells_list}
       Append To List    ${impacted_cell_dn_list}    ${CELL_lcrId_dn_dict["${lcr_id_impacted_cell}"]}
    END
    [Return]   ${impacted_cell_dn_list}

Detect POWERGROUP in BBPOOL
    [Arguments]    ${bbPwrGroupDNList}    ${searched_PowerGroup}
    ${POWERGROUP_exists}=    Set Variable    ${FALSE}
    FOR    ${POWERGROUP_DN}    IN    @{bbPwrGroupDNList}
       ${POWERGROUP_exists}=    Set Variable If   '${searched_PowerGroup}' == '${POWERGROUP_DN}'    ${TRUE}    ${POWERGROUP_exists}
    END
    [Return]    ${POWERGROUP_exists}

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

Get L1SoC RMOD eligible for CB010846
    [Arguments]  ${L1SoC_shared_RMOD_id_list}  ${L1SoC_dedicated_RMOD_id_list}  ${alias}

    ${CB010846_L1SoC_shared_RMOD_sn_list}=  Create List
    ${CB010846_L1SoC_dedicated_RMOD_sn_list}=  Create List

    ${CB010846_shared_RMOD_sn_list}=  Get From Dictionary  ${BTS_alias_CB010846_shared_RMOD_sn_dict}  ${alias}
    FOR  ${RMOD_sn}  IN  @{CB010846_shared_RMOD_sn_list}

        ${RMOD_id}=  Get From Dictionary  ${${alias}_MODULE_sn_id_mapping_dict}  ${RMOD_sn}
        Run Keyword If  '${RMOD_id}' in ${L1SoC_shared_RMOD_id_list}
        ...  Append To List  ${CB010846_L1SoC_shared_RMOD_sn_list}  ${RMOD_sn}

    END

    ${CB010846_dedicated_RMOD_sn_list}=  Get From Dictionary  ${BTS_alias_CB010846_dedicated_RMOD_sn_dict}  ${alias}
    FOR  ${RMOD_sn}  IN  @{CB010846_dedicated_RMOD_sn_list}

        ${RMOD_id}=  Get From Dictionary  ${${alias}_MODULE_sn_id_mapping_dict}  ${RMOD_sn}
        Run Keyword If  '${RMOD_id}' in ${L1SoC_dedicated_RMOD_id_list}
        ...  Append To List  ${CB010846_L1SoC_dedicated_RMOD_sn_list}  ${RMOD_sn}

    END

    [Return]  ${CB010846_L1SoC_shared_RMOD_sn_list}  ${CB010846_L1SoC_dedicated_RMOD_sn_list}

Perform uncontrolled BBMOD L1SoC reset via PID kill
    [Arguments]  ${BBMOD_id}  ${BBMOD_sn}  ${SoC_Index}  ${alias}

    ${BBMOD_SMOD_info_dict}=  Get BBMOD and SMOD position in subrack  ${BBMOD_id}  ${alias}
    ${BBMOD_verticalPosition}=  Get From Dictionary  ${BBMOD_SMOD_info_dict}  BBMOD_verticalPosition
    ${BBMOD_verticalPosition}=  Evaluate  ${BBMOD_verticalPosition} - 1
    Log  - BBMOD with SN ${BBMOD_sn} vertical position in subrack is: ${BBMOD_verticalPosition}  console=True

    ${SMOD_activeRole}=  Get From Dictionary  ${BBMOD_SMOD_info_dict}  SMOD_activeRole
    ${SMOD_alias}=  Set Variable If  '${SMOD_activeRole}' == 'Primary' or '${SMOD_activeRole}' == 'None'  ${alias.upper()}  ${alias.upper()}_EXT

    ${cond}=  Set Variable  '${alias}'=='Master' and ('${SMOD_activeRole}' == 'Primary' or '${SMOD_activeRole}' == 'None')
    ${remote_host}=  Set Variable If  ${cond}  None  ${${SMOD_alias}}[${SMOD_alias}_PC_IP_ADDRESS]
    ${ip_address}=  Set Variable  ${${SMOD_alias}}[${SMOD_alias}_TECH_IP_ADDRESS]

    ${bsh}=  Set Variable  ${BBMOD_verticalPosition}:${SoC_Index}

    ${bsh_get_PID_process}=  Set Variable  ps -eaf | grep ${L1_PROCESS_NAME} | grep -v grep | awk '{print $2}'
    ${PID_process}=  Execute BSH Command  bsh=${bsh}  command=${bsh_get_PID_process}  target_ip=${ip_address}  via_ip=${remote_host}
    ...  alias=${alias}_ssh
    Should Not Be Empty  ${PID_process}

    ${PID_process}=  Convert To Integer  ${PID_process}
    Log  - BBMOD with SN ${BBMOD_sn} PID for ${L1_PROCESS_NAME} process is: ${PID_process}  console=True

    ${bsh_kill_PID_process}=  Set Variable  kill -11 ${PID_process}
    Log Long String  Triggering L1SoC-${SoC_Index} autonomous reset operation on BBMOD with SN ${BBMOD_sn} from BTS ${alias} with bsh command:
    ...  kill -11 ${PID_process}  console=True

    ${kill_PID_process}=  Execute BSH Command  bsh=${bsh}  command=${bsh_kill_PID_process}  target_ip=${ip_address}  via_ip=${remote_host}
    ...  alias=${alias}_ssh

Get BBMOD RMOD ports mapping
    [Arguments]    ${BBMOD_sn}  ${alias}
    ${shared_RMOD_sn_list}=  Get From Dictionary  ${BTS_alias_shared_RMOD_sn_dict}  ${alias}
    ${dedicated_RMOD_sn_list}=  Get From Dictionary  ${BTS_alias_dedicated_RMOD_sn_dict}  ${alias}
    ${all_RMOD_sn_list}=  Combine Lists  ${shared_RMOD_sn_list}  ${dedicated_RMOD_sn_list}
    ${BBMOD_RMODs_ports_mapping}=  Create Dictionary
    FOR  ${RMOD_sn}  IN  @{all_RMOD_sn_list}
        ${firstModule_connectorLabel_linkModeSynchronization_dict}  ${secondModule_connectorLabel_linkModeSynchronization_dict}
        ...  ${firstModule_connectorLabel_linkModeConfiguration_dict}  ${secondModule_connectorLabel_linkModeConfiguration_dict}
        ...  ${firstModule_secondModule_connectorLabel}  ${secondModule_firstModule_connectorLabel}
        ...  Get linkModeSynchronization and linkModeConfiguration info dict  ${BBMOD_sn}  ${RMOD_sn}  ${alias}
        ${BBMOD_RMOD_list}=    Create List
        ...  ${firstModule_connectorLabel_linkModeSynchronization_dict}  ${secondModule_connectorLabel_linkModeSynchronization_dict}
        ...  ${firstModule_connectorLabel_linkModeConfiguration_dict}  ${secondModule_connectorLabel_linkModeConfiguration_dict}
        ...  ${firstModule_secondModule_connectorLabel}  ${secondModule_firstModule_connectorLabel}
        Set To Dictionary    ${BBMOD_RMODs_ports_mapping}   ${RMOD_sn}=${BBMOD_RMOD_list}
    END
    [Return]  ${BBMOD_RMODs_ports_mapping}

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

Get BTS cells mapped on RMOD impact due to reset L1SoC on BBMOD
    [Arguments]   ${L1SoC_disabled_RMOD_id_list}  ${alias}

    ${L1SoC_impacted_NR_CELL_id_list}=  Create List
    ${L1SoC_impacted_LTE_CELL_id_list}=  Create List
    ${L1SoC_impacted_WCDMA_CELL_id_list}=  Create List
    ${L1SoC_impacted_GSM_CELL_id_list}=  Create List
    ${L1SoC_disabled_RMOD_CELL_id_list}=  Create List

    ${L1SoC_CELL_id_list}=  Create List

    FOR  ${item}  IN  @{L1SoC_disabled_RMOD_id_list}

        ${CELL_id_list}=  Get Cell Mapping By Module Id  module_id=${item}  connection=${alias}
        Append To List  ${L1SoC_disabled_RMOD_CELL_id_list}  @{CELL_id_list}

    END

    ${BBMOD_disabled_RMOD_CELL_id_list}=  Remove Duplicates  ${L1SoC_disabled_RMOD_CELL_id_list}
    Sort List  ${L1SoC_disabled_RMOD_CELL_id_list}

    FOR  ${CELL_id}  IN  @{L1SoC_disabled_RMOD_CELL_id_list}

        Run Keyword If  '${CELL_id}' in ${${alias}_NR_CELL_id_list}  Append To List  ${L1SoC_impacted_NR_CELL_id_list}  ${CELL_id}
        ...  ELSE IF  '${CELL_id}' in ${${alias}_LTE_CELL_id_list}   Append To List  ${L1SoC_impacted_LTE_CELL_id_list}  ${CELL_id}
        ...  ELSE IF  '${CELL_id}' in ${${alias}_WCDMA_CELL_id_list}  Append To List  ${L1SoC_impacted_WCDMA_CELL_id_list}  ${CELL_id}
        ...  ELSE IF  '${CELL_id}' in ${${alias}_GSM_CELL_id_list}   Append To List  ${L1SoC_impacted_GSM_CELL_id_list}  ${CELL_id}

    END

    [Return]  ${L1SoC_impacted_NR_CELL_id_list}  ${L1SoC_impacted_LTE_CELL_id_list}  ${L1SoC_impacted_WCDMA_CELL_id_list}
    ...  ${L1SoC_impacted_GSM_CELL_id_list}

Check BTS Item State
    [Arguments]  ${alias}  ${BTS_item_class}  ${BTS_item_list}  ${BTS_item_state_check}  ${BTS_item_state}  ${timeout}  ${check_exceptions}=False

    FOR  ${item}  IN  @{BTS_item_list}
        ${item_param}=  Get Parameters For  class_name=${BTS_item_class}  id_num=${item}  connection=${alias}
        ${RM_EXCEPTION}=  Run Keyword And Return Status  Should Contain  ${RMOD_ECPRI_fid16_exceptions}  ${item_param['productName']}
        Run Keyword If  '${RM_EXCEPTION}' == 'True' and '${check_exceptions}' == 'False'  Run Keywords
        ...  Log  Skipping state check for ${item} as it is part of exception list: ${item_param['productName']}  console=True
        ...  AND  Continue For Loop
        Assert  class_name=${BTS_item_class}  id=${item}  parameters=${BTS_item_state_check}  timeout=${timeout}  connection=${alias}
        Log  BTS ${alias} ${BTS_item_class} ${item} status:\n - ${BTS_item_state}  console=True
    END

Check peer BTS CPRI shared RMODs status with CB007447 feature activated
    [Arguments]  ${CPRI_shared_RMOD_id_list}  ${date_timestamp_start_UTC}  ${date_timestamp_end_UTC}  ${alias}

    Log  Check BTS ${alias} CPRI shared RMODs status with CB007447 feature activated:  console=True

    ${RMOD_status_dict}=  Create Dictionary  operationalState=enabled
    ${ims_file_path}=  Admin Collect IMS file with timestamp  folder_path=${Test Results Dir}/IMS/${alias}  alias=${alias}

    FOR  ${RMOD_id}  IN  @{CPRI_shared_RMOD_id_list}

        Check object parameters values are not changed from IMS file  ${ims_file_path}  ${RMOD_id}  ${RMOD_status_dict}  ${date_timestamp_start_UTC}
        ...  ${date_timestamp_end_UTC}  ${TRUE}  ${TRUE}

    END

    Log  BTS ${alias} CPRI shared RMODs status with CB007447 feature activated as expected  console=True

Check all BTS reset behavior based on IMS info
    [Documentation]
    ...  BTS RESET info is checked based on IMS info. Reset behavior as expected if no BTS reset occurs.
    ...  Otherwise, reset behavior not as expected, then errors are added to report and failed.
    [Arguments]  ${alias}

    Log  Check all BTS reset behavior based on IMS info  console=True

    Get and check BTS RESET info from IMS file  expected_reset_number=0  alias=${alias}
    ...  start_point_timestamp_UTC=${date_timestamp_start_resetL1SoC_UTC}  end_point_timestamp_UTC=${date_timestamp_end_resetL1SoC_UTC}

    FOR  ${other_alias}  IN  @{alias_list}

        Continue For Loop If  '${other_alias}' == '${alias}'

        Get and check BTS RESET info from IMS file  expected_reset_number=0  alias=${other_alias}
        ...  start_point_timestamp_UTC=${date_timestamp_start_resetL1SoC_UTC}  end_point_timestamp_UTC=${date_timestamp_end_resetL1SoC_UTC}

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

    ${CB010846_L1SoC_shared_RMOD_count}=  Get Length  ${CB010846_L1SoC_shared_RMOD_sn_list}

    Run Keyword If  ${CB010846_L1SoC_shared_RMOD_count} > 0
    ...  Check RMOD reset behavior on BTS  RMOD_sn_list=${CB010846_L1SoC_shared_RMOD_sn_list}  alias=${alias}
    ...  ELSE
    ...  Log  No BBMOD shared RMODs eligible for CB010846 feature on BTS ${alias}  console=True

    Log  Check BTS ${alias} BBMOD dedicated RMOD eligible for CB010846 feature reset behavior based on Uptime info  console=True

    ${CB010846_L1SoC_dedicated_RMOD_count}=  Get Length  ${CB010846_L1SoC_dedicated_RMOD_sn_list}

    Run Keyword If  ${CB010846_L1SoC_dedicated_RMOD_count} > 0
    ...  Check RMOD reset behavior on BTS  RMOD_sn_list=${CB010846_L1SoC_dedicated_RMOD_sn_list}  alias=${alias}
    ...  ELSE
    ...  Log  No BBMOD dedicated RMODs eligible for CB010846 feature on BTS ${alias}  console=True

    FOR  ${other_alias}  IN  @{alias_list}

        Continue For Loop If  '${other_alias}' == '${alias}'

        Log  Check BTS ${other_alias} shared RMODs eligible for CB010846 feature reset behavior based on Uptime info  console=True

        ${BTS_peer_CB010846_BBMOD_shared_RMOD_sn_list}=  Get peer BTS shared RMOD  ${CB010846_L1SoC_shared_RMOD_sn_list}  ${other_alias}
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

    Run Keyword If  ${CB010846_L1SoC_shared_RMOD_count} > 0  Run Keywords
    ...  Log  Get Primary Link status (linkModeSynchronization) for BBMOD shared RMODs eligible for CB010846:  console=True
    ...  AND  Get shared RMOD synchronisation info on both BTS  shared_RMOD_sn_list=${CB010846_L1SoC_shared_RMOD_sn_list}

Clear FID6450 by BTS Snapshot collect
    [Arguments]  ${alias}

    ${FID6450_status}=  Run Keyword And Return Status  Assert Alarm Active  parameters=faultId=6450  timeout=60  alias=${alias}

    Return From Keyword If  '${FID6450_status}' == 'False'

    Log  Wait for clear "Diagnostic files collected (6450)" alarm on BTS ${alias} by collect snapshot  console=True

    ${target_file_name}=  Set Variable  ${Test Results Dir}/${alias}_L1SoC_Operation/Clear_FID6450_snapshot.zip

    OperatingSystem.Remove File  ${target_file_name}

    coam.Collect Snapshot  alias=${alias}  target_file_name=${target_file_name}  timeout=1260

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

Get CELL ID from CELL dn
    [Arguments]    ${cell_dn_searched}  ${cell_type}  ${alias}

    ${cells_info}=  Get Cells Info  cell_type=${cell_type}  connection=${alias}
    FOR    ${item}    IN    @{cells_info}
        ${cell_id}=  Get From Dictionary  ${item["id"]}  internal
        ${cell_dn}=  Get From Dictionary  ${item["id"]}  configuration
        Return From Keyword If  '${cell_dn}'=='${cell_dn_searched}'  ${cell_id}
    END
    Fail   Could not find cell ID corresponding to cell dn ${cell_dn_searched} on BTS ${alias}!

Set shared RMOD Primary Link before BBMOD L1SoC Reset operation
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

Recover initial settings for CB010846 feature
    [Documentation]
    ...  Keyword used to recover initial settings for CB010846 feature

    [Arguments]  ${alias}

    Log  Recover initial settings for CB010846 feature on BTS ${alias}  console=True
    ${actRuResetResiliency_initial}=  Get From Dictionary  ${${alias}_BTS_CB010846_feature_dict}  actRuResetResiliency
    Set classical BTS CB010846 feature parameter  actRuResetResiliency  ${actRuResetResiliency_initial}  ${alias}
    ${uncntrldResetMplaneBreakTime_initial}=  Get From Dictionary  ${${alias}_BTS_CB010846_feature_dict}  uncntrldResetMplaneBreakTime
    Set classical BTS CB010846 feature parameter  uncntrldResetMplaneBreakTime  ${uncntrldResetMplaneBreakTime_initial}  ${alias}

Particular Teardown
    FOR  ${alias}  IN  @{alias_list}

        Recover initial settings for CB010846 feature  ${alias}

    END

TC Setup
    ${tech_preset_list}=  Create List  SBTS  SBTS
    Common Test Setup  preset_techs=${tech_preset_list}  common_sbts=${TRUE}  infomodelSetup=${FALSE}

TC Teardown
    Common Test Teardown
