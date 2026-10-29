*** Settings ***
Documentation    TC__SBTS_SBTS_SBTS_SBTS__STATE__Site_Reset_without_RU_reset_CB012446
Variables    tc_variables/sbts_sbts_sbts_sbts__state__site_reset_without_ru_reset_cb012446_alarms_definitions.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${REPEAT_COUNTER}                  3      # Number of Reset Site without RU reset operations on both BTS, default value 3
${BTS_LIST}                        ALL    # List of BTS where the action needs to be performed. Eg. ALL, or BTS2 or BTS1,BTS3 etc.
                                          # CB012446 feature is not supported on BTS with FSMF SMOD
${cntrldResetMplaneBreakTimeSite}  300    # Maximum time when RU tries to re-establish released M-plane connection to BTS after a site reset
                                          # without RU reset. Should be in range: 180 - 420 (seconds), by default 300
${BTS1_RESET_WRN_THR}  600                # Time (secs) spent between first cell down to last cell up on BTS1
                                          # Default value: in accordance with KPI1a specifications
${BTS2_RESET_WRN_THR}  600                # Time (secs) spent between first cell down to last cell up on BTS2
                                          # Default value: in accordance with KPI1a specifications
${BTS3_RESET_WRN_THR}  600                # Time (secs) spent between first cell down to last cell up on BTS3
                                          # Default value: in accordance with KPI1a specifications
${BTS4_RESET_WRN_THR}  600                # Time (secs) spent between first cell down to last cell up on BTS4
                                          # Default value: in accordance with KPI1a specifications
${BTS_MAX_WAIT_TIME}               900    # Maximum time to wait for BTS OnAir after reset, by default 900
${GRACEFUL_CELL_SHUTDOWN}          True   # Graceful cell shutdown: True or False, by default True
${CB007447_SHARED_RM_SN_EXCEPTIONS_LIST}  # CPRI shared RM serial number list separated by comma that don't support feature CB007447 (only in case
                                          # CB007447 is activated)
${CB012446_SHARED_RM_SN_EXCEPTIONS_LIST}  # CPRI shared RM serial number list separated by comma that don't support feature CB007447 (only in case
                                          # CB012446 is activated)

*** Keywords ***
TC__SBTS_SBTS_SBTS_SBTS__STATE__Site_Reset_without_RU_reset_CB012446
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-27854
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  SBTS-SBTS test case for both BTS Reset Site without RU reset operation, - x times sequence.
    ...  x - value of REPEAT_COUNTER parameter (default: 3)
    ...  The main steps performed for the test are:
    ...  - check initial state and alarms for both BTS
    ...  - get and check CB012446 settings on both BTS
    ...  - get primary link settings for shared RMOD before Reset Site without RU reset operation on BTS
    ...  - perform Reset Site without RU reset operation on BTS checking states and alarms on both BTS
    ...  - check reset behavior on both BTS based on info from IMS file as follows:
    ...    - BTS: reset number is 1
    ...    - peer BTS: reset number is 0
    ...  - check states and alarms for both BTS after Reset Site without RU reset operation on BTS2
    ...  Pass criteria: Reset Site without RU reset operation works as expected, states and alarms are as expected
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 23.09.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27854 -
    ...  [CB012446][5G] StartUp Improvement - New Testcase : Site Reset without RM restart
    ...  - 24.10.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28271 -
    ...  [CB012446][5G] SBTS_SBTS__STATE__Site_Reset_without_RU_reset_CB012446.robot to be modified for shared CPRI radios
    ...  - 29.01.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28609 -
    ...  [CB012446] Add enhancement for SBTS_SBTS__STATE__Site_Reset_without_RU_reset_CB012446.robot when CB007447 is active
    ...  - 10.10.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29932 - Site_Reset_without_RU_reset_CB012446 robots should be modified
    ...  for no dependency of CB010846
    ...  - 30.10.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28998 -
    ...  [5G]SBTS_SBTS__STATE__Site_Reset_without_RU_reset_CB012446- should support for 3 BTS
    ...  - 27.11.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30221 - Remove ${actForceUnitAutoReset}' in tests and KWs related to CB007447
    ...  - 03.03.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30579 - Check basic TA KWs RF 8 AXEGHA ORAN-ECPRI impact

    Set Tags    CA-STATE    OWNER-georgiana.stefan@nokia.com    AUTHOR-dinu.olariu@nokia.com    PHASE-QT    SW-SBTS25R1

    TC Preconditions
    Step 1: Check initial all BTS state
    Step 2: Check initial all BTS alarms
    Step 3: Check CB012446 feature settings
    Step 4: Get all BTS info for configured items
    FOR  ${INDEX}  IN RANGE  1  ${REPEAT_COUNTER}+1
        Log  ==============================================================================  console=True
        Log  Start Cycle ${INDEX} of ${REPEAT_COUNTER}  console=True
        Log  ==============================================================================  console=True
        Step 5: Perform Reset Site without RU reset operation on all BTS for iteration ${INDEX}
        Step 6: Check final all BTS state
        Step 7: Check final all BTS alarms
        Step 8: Check final number and state of Cells and RMs
    END

    [Teardown]  Particular Teardown

TC Preconditions
    ${BTS_alias_label_dict}  ${BTS_label_alias_dict}=  Get BTS alias label info dict
    ${BTS_LIST_explicit}=  Set Variable If  '${BTS_LIST}'=='ALL'  BTS1,BTS2,BTS3,BTS4  ${BTS_LIST}
    IF  '${BTS_LIST}'!='ALL'
        Check BTS list  ${BTS_LIST_explicit}  ${BTS_label_alias_dict}
    END
    Set Test Variable  ${BTS_alias_label_dict}
    Set Test Variable  ${BTS_list_explicit}

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

        Get and Check Alarms SOAM  alias=${alias}  expected_alarms=@{EMPTY}
        ...  ignored_alarms=${test_alarms_list['${alias.upper()}_IGNORED_ALARMS']}
        ...  critical_alarms=${test_alarms_list['${alias.upper()}_CRITICAL_ALARMS']}

        Log  BTS ${alias} site - expected, ignored and critical alarms checked  console=True

    END

Step ${index}: Check CB012446 feature settings
    [Documentation]
    ...  Check CB012446 feature settings on BTS

    Log  Step ${index}: Check CB012446 feature settings  console=True

    FOR  ${alias}  IN  @{alias_list}

        IF  not '${BTS_alias_label_dict}[${alias}]' in '${BTS_LIST_explicit}'    CONTINUE

        Log  Check CB012446 feature settings on BTS ${alias} and set them accordingly if needed  console=True

        ${BTS_CB012446_feature_dict}=  Get BTS CB012446 feature parameters  BTS_SCF_path_file=${${alias.lower()}_scf_initial}  alias=${alias}

        Set Test Variable  ${${alias}_BTS_CB012446_feature_dict}  ${BTS_CB012446_feature_dict}

        Set classical BTS CB012446 feature parameter  cntrldResetMplaneBreakTimeSite  ${cntrldResetMplaneBreakTimeSite}  ${alias}

    END

    Log  Get CB007447 feature status  console=True

    FOR  ${alias}  IN  @{alias_list}

        Log  Get CB007447 feature status on BTS ${alias}  console=True

        ${actCpriLinkRecovery}  ${actSyncLinkSwitchover}  ${cpriSyncBreakTime}  ${stickToSyncSourcePeriod}=  Get feature CB007447 info  ${alias}

        ${condition}=  Create Long String  '${actCpriLinkRecovery}' == 'true' and '${actSyncLinkSwitchover}' == 'true'

        IF  ${condition}
            Log  BTS ${alias} CB007447 feature status: Enabled  console=True
            Set Test Variable  ${${alias}_CB007447_status}  ${TRUE}
        ELSE
            Log  BTS ${alias} CB007447 feature status: Disabled  console=True
            Set Test Variable  ${${alias}_CB007447_status}  ${FALSE}
        END

    END

    ${CB007447_EXCEPTIONS}=  Create Dictionary
    ...  exception_for_CB007447_eligible=${CB007447_SHARED_RM_SN_EXCEPTIONS_LIST}
    Set Test Variable  ${CB007447_EXCEPTIONS}
    ${CB012446_EXCEPTIONS}=  Create Dictionary
    ...  exception_for_CB012446_eligible=${CB012446_SHARED_RM_SN_EXCEPTIONS_LIST}
    Set Test Variable  ${CB012446_EXCEPTIONS}

Check BTS list
    [Arguments]  ${BTS_LIST}  ${BTS_label_alias_dict}

    ${BTS_LIST_strip}=  Replace String  ${BTS_LIST}  ${SPACE}  ${EMPTY}
    ${BTS_LIST_split}=  Split String  ${BTS_LIST_strip}  ,
    ${BTS_check}=  Set Variable  True
    ${BTS_invalid_label_list}=  Create List
    ${BTS_request_label_list}=  Create List
    ${BTS_request_alias_list}=  Create List

    FOR  ${item}  IN  @{BTS_LIST_split}
        ${BTS_check}=  Set Variable If  '${item}' not in ${BTS_label_alias_dict}  False  ${BTS_check}
        IF  '${item}' not in ${BTS_label_alias_dict}
            Append To List  ${BTS_invalid_label_list}  ${item}
        ELSE
            Append To List  ${BTS_request_label_list}  ${item}
        END
    END

    IF  '${BTS_check}' == 'False'
        Log Long String  Following selected BTS are not valid: ${BTS_invalid_label_list}.
        ...  Please select values for test argument \${BTS_LIST} from
        ...  configured BTS: ${BTS_LIST} or let default value: ALL  console=True
        Fail  Improper value for argument!
    END

Step ${index}: Get all BTS info for configured items
    [Documentation]
    ...  Get all BTS info about following items:
    ...  - list of shared and dedicated RMOD serial number on BTS
    ...  - list of shared and dedicated RMOD serial number eligible for CB012446 on BTS

    Log  Step ${index}: Get all BTS info for configured items  console=True

    Get all BTS SMOD BBMOD list

    ${BTS_alias_RMOD_sn_dict}  ${RMOD_sn_BTS_alias_dict}  ${shared_RMOD_sn_list}  ${dedicated_RMOD_sn_list}=  Get all BTS RMOD sharing info
    Set Test Variable  ${RMOD_sn_BTS_alias_dict}

    IF  '${CB007447_SHARED_RM_SN_EXCEPTIONS_LIST}' != ''
        Check RM CPRI CB0012446 CB007447 validity  ${shared_RMOD_sn_list}
    ELSE
        Set Test Variable  @{CB007447_shared_RM_sn_exceptions_list}  @{EMPTY}
    END

    Set Test Variable  ${RMOD_state_enabled_check}  operationalState=${Enabled_}, administrativeState=${Unlocked_}
    Set Test Variable  ${RMOD_state_enabled}  operationalState=Enabled, administrativeState=Unlocked

Step ${index}: Perform Reset Site without RU reset operation on all BTS for iteration ${CYCLE}

    Log  Step ${index}: Perform Reset Site without RU reset operation on all BTS for iteration ${CYCLE}  console=True

    Set Test Variable  ${CYCLE}

    FOR  ${alias}  IN  @{alias_list}

        IF  not '${BTS_alias_label_dict}[${alias}]' in '${BTS_LIST_explicit}'    CONTINUE

        Perform Reset Site without RU reset operation on BTS  ${alias}

        Check all BTS reset behavior based on IMS info  ${alias}  ${peer_aliases}

        Check all BTS requested RMOD reset behavior based on Uptime info  ${alias}  ${peer_aliases}

        Get and check KPI1f info from IMS file  ${alias}  ${CYCLE}

    END

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]
    ...  Following checks are performed:
    ...  - number of configured cells and radio modules in SCF are properly mapped on BTS running view ADMIN
    ...  - check cells states
    ...  - check radio modules states

    Log  Step ${index}: Check final number and state of Cells and RMs  console=True
    RFS Test Case Final Checks

Check RM CPRI CB0012446 CB007447 validity
    [Arguments]    ${shared_RMOD_sn_list}

    ${CB007447_SHARED_RM_SN_EXCEPTIONS_LIST_strip}=  Replace String  ${CB007447_SHARED_RM_SN_EXCEPTIONS_LIST}  ${SPACE}  ${EMPTY}
    ${CB007447_SHARED_RM_SN_EXCEPTIONS_LIST}=  Split String  ${CB007447_SHARED_RM_SN_EXCEPTIONS_LIST}  ,
    ${CB007447_SHARED_RM_SN_EXCEPTIONS_check}=  Set Variable  True
    ${CB007447_SHARED_RM_SN_EXCEPTIONS_invalide_list}=  Create List

    FOR  ${item}  IN  @{CB007447_SHARED_RM_SN_EXCEPTIONS_LIST}
        ${CB007447_SHARED_RM_SN_EXCEPTIONS_check}=  Set Variable If
        ...  '${item}' not in ${shared_RMOD_sn_list}  False  ${CB007447_SHARED_RM_SN_EXCEPTIONS_check}
        IF  '${item}' not in ${shared_RMOD_sn_list}    Append To List  ${CB007447_SHARED_RM_SN_EXCEPTIONS_invalide_list}  ${item}
    END

    IF  '${CB007447_SHARED_RM_SN_EXCEPTIONS_check}' == 'False'
        Log  Following selected shared RM serial number values are not valid: ${CB007447_SHARED_RM_SN_EXCEPTIONS_invalide_list}.  console=True
        Log  Please select values for test argument \${CB007447_SHARED_RM_SN_EXCEPTIONS_LIST} from configured shared RM: ${shared_RMOD_sn_list}
        ...  console=True
    END

    ${CB012446_SHARED_RM_SN_EXCEPTIONS_LIST_strip}=  Replace String  ${CB012446_SHARED_RM_SN_EXCEPTIONS_LIST}  ${SPACE}  ${EMPTY}
    ${CB012446_SHARED_RM_SN_EXCEPTIONS_LIST}=  Split String  ${CB012446_SHARED_RM_SN_EXCEPTIONS_LIST}  ,
    ${CB012446_SHARED_RM_SN_EXCEPTIONS_check}=  Set Variable  True
    ${CB012446_SHARED_RM_SN_EXCEPTIONS_invalide_list}=  Create List

    FOR  ${item}  IN  @{CB012446_SHARED_RM_SN_EXCEPTIONS_LIST}
        ${CB012446_SHARED_RM_SN_EXCEPTIONS_check}=  Set Variable If
        ...  '${item}' not in ${shared_RMOD_sn_list}  False  ${CB012446_SHARED_RM_SN_EXCEPTIONS_check}
        IF  '${item}' not in ${shared_RMOD_sn_list}    Append To List  ${CB012446_SHARED_RM_SN_EXCEPTIONS_invalide_list}  ${item}
    END

    IF  '${CB012446_SHARED_RM_SN_EXCEPTIONS_check}' == 'False'
        Log  Following selected shared RM serial number values are not valid: ${CB012446_SHARED_RM_SN_EXCEPTIONS_invalide_list}.  console=True
        Log  Please select values for test argument \${CB012446_SHARED_RM_SN_EXCEPTIONS_LIST} from configured shared RM: ${shared_RMOD_sn_list}
        ...  console=True
    END

    IF  '${CB007447_SHARED_RM_SN_EXCEPTIONS_check}' == 'False' or '${CB012446_SHARED_RM_SN_EXCEPTIONS_check}' == 'False'
        Fail  Improper value for argument!
    END

Get all BTS shared RMOD info
    [Arguments]  ${BTS_alias_RMOD_sn_dict}  ${shared_RMOD_sn_list}

    ${BTS_alias_shared_RMOD_sn_dict}=  Create Dictionary

    FOR  ${alias}  IN  @{alias_list}

        ${BTS_RMOD_sn_list}=  Get From Dictionary  ${BTS_alias_RMOD_sn_dict}  ${alias}

        ${BTS_shared_RMOD_sn_list}=  Get BTS configured RMOD list  ${BTS_RMOD_sn_list}  ${shared_RMOD_sn_list}

        Set To Dictionary  ${BTS_alias_shared_RMOD_sn_dict}  ${alias}  ${BTS_shared_RMOD_sn_list}

    END

    RETURN  ${BTS_alias_shared_RMOD_sn_dict}

Get all BTS dedicated RMOD info
    [Arguments]  ${BTS_alias_RMOD_sn_dict}  ${dedicated_RMOD_sn_list}

    ${BTS_alias_dedicated_RMOD_sn_dict}=  Create Dictionary

    FOR  ${alias}  IN  @{alias_list}

        ${BTS_RMOD_sn_list}=  Get From Dictionary  ${BTS_alias_RMOD_sn_dict}  ${alias}

        ${BTS_dedicated_RMOD_sn_list}=  Get BTS configured RMOD list  ${BTS_RMOD_sn_list}  ${dedicated_RMOD_sn_list}

        Set To Dictionary  ${BTS_alias_dedicated_RMOD_sn_dict}  ${alias}  ${BTS_dedicated_RMOD_sn_list}

    END

    RETURN  ${BTS_alias_dedicated_RMOD_sn_dict}

Get BTS configured RMOD list
    [Arguments]  ${BTS_RMOD_sn_list}  ${configured_RMOD_sn_list}

    ${BTS_configured_RMOD_sn_list}=  Create List

    FOR  ${RMOD_sn}  IN  @{BTS_RMOD_sn_list}

        IF  '${RMOD_sn}' not in ${configured_RMOD_sn_list}    CONTINUE

        Append To List  ${BTS_configured_RMOD_sn_list}  ${RMOD_sn}

    END

    Sort List  ${BTS_configured_RMOD_sn_list}

    RETURN  ${BTS_configured_RMOD_sn_list}

Perform Reset Site without RU reset operation on BTS
    [Arguments]  ${alias}

    Log  Get BTS impact info due to ${alias} Site Reset  console=True
    Get BTSs impact info due to Site Reset
    ...  alias=${alias}
    ...  CB007447_EXCEPTIONS=${CB007447_EXCEPTIONS}  CB012446_EXCEPTIONS=${CB012446_EXCEPTIONS}

    ${hostname_ip}=  Set Variable  ${${alias.upper()}}[${alias.upper()}_TECH_IP_ADDRESS]
    ${remote_host_ip}=  Set Variable If  '${alias}' == 'Master'  None  ${${alias.upper()}}[${alias.upper()}_PC_IP_ADDRESS]

    Log  ***** Perform Reset Site without RU reset operation on BTS ${alias} *****  console=True

    IF  ${own_BBMOD_enabled_shared_CPRI_RMOD_id_list_012446_no_007447}
        Log  Get Primary Link status (linkModeSynchronization) for shared RMODs eligible for CB012446:  console=True
    END
    IF  ${own_BBMOD_enabled_shared_CPRI_RMOD_id_list_012446_no_007447}
        ${CPRI_CB012446_shared_RMOD_sn_BTS_alias_linkModeSynchronization_info_dict}=
        ...  Get shared RMOD synchronisation info on both BTS
        ...  shared_RMOD_sn_list=${own_BBMOD_enabled_shared_CPRI_RMOD_id_list_012446_no_007447}
    END

    IF  ${own_BBMOD_enabled_shared_CPRI_RMOD_id_list_012446_no_007447}
        Set Test Variable  ${CPRI_CB012446_shared_RMOD_sn_BTS_alias_linkModeSynchronization_info_dict_initial}
        ...  ${CPRI_CB012446_shared_RMOD_sn_BTS_alias_linkModeSynchronization_info_dict}
    END

    ${BTS_alias_RMOD_sn_Uptime_dict_initial}=  Get all BTS RMOD Uptime info
    Set Test Variable  ${BTS_alias_RMOD_sn_Uptime_dict_initial}

    Log  Reset Site without RU reset on BTS ${alias}  console=True

    Get Current Date UTC info  initial
    Get Current Time  initial
    ${GRACEFUL_CELL_SHUTDOWN}=  Convert To Boolean  ${GRACEFUL_CELL_SHUTDOWN}
    RFS Site Reset  graceful_cell_shutdown=${GRACEFUL_CELL_SHUTDOWN}  reset_without_ru=${TRUE}  connection=${alias}

    Wait For Target To Be Not Reachable TAF  hostname=${hostname_ip}  remote_host=${remote_host_ip}  timeout=300

    Wait For Target To Be Reachable TAF  hostname=${hostname_ip}  remote_host=${remote_host_ip}  timeout=300

    Check BTS states and alarms after BTS reset  ${alias}

    Check peer BTS states and alarms after BTS reset  ${alias}  ${peer_aliases}

    Get Current Date UTC info  final

    Check peer BTS alarms during BTS reset from ims   ${alias}  ${peer_aliases}  ${date_timestamp_initial_UTC}

    Check all peer BTS CPRI shared RMODs status with CB007447 feature activated
    ...  ${date_timestamp_initial_UTC}  ${date_timestamp_final_UTC}  ${peer_aliases}

Get all BTS SMOD BBMOD list

    FOR  ${alias}  IN  @{alias_list}

       ${SMOD_id_list}=  Get Ids For All  class_name=SMOD  connection=${alias}
       ${BBMOD_id_list}=  Get Ids For All  class_name=BBMOD  connection=${alias}
       ${BTS_MOD_id_list}=  Combine Lists  ${SMOD_id_list}  ${BBMOD_id_list}
       Set Test Variable  ${${alias}_MOD_id_list}  ${BTS_MOD_id_list}

    END

Get BTSs impact info due to Site Reset
    [Arguments]  ${alias}  ${CB007447_EXCEPTIONS}=&{Empty}  ${CB012446_EXCEPTIONS}=&{Empty}

    ${SMOD_BBMOD_id_dict}=  Create Dictionary  Equipment_reset=${${alias}_MOD_id_list}
    ${TL_detailed_equipment_dict}=  Get Testline equipment connected by Cablink
    ...  ${SMOD_BBMOD_id_dict}
    ...  ${alias}
    ...  ${alias_list}
    ...  Reset_dependency_rules=${Reset_dependency_rules}
    ...  CPRI_SN_EXCEPTIONS=&{Empty}
    ...  ECPRI_SN_EXCEPTIONS=&{Empty}
    ...  ECPRI_NETCONF_SN_EXCEPTIONS=&{Empty}
    ...  OBSAI_SN_EXCEPTIONS=&{Empty}
    ...  CB007447_EXCEPTIONS=${CB007447_EXCEPTIONS}
    ...  CB012446_EXCEPTIONS=${CB012446_EXCEPTIONS}
    ${detailed_dependent_equipment_dict}=  Get From Dictionary  ${TL_detailed_equipment_dict}  ${alias}

    ${peer_aliases}=  Get Dictionary Keys  ${TL_detailed_equipment_dict}
    Remove Values From List  ${peer_aliases}  ${alias}
    Set Test Variable  ${peer_aliases}

    Get Site Reset Impact On BTS  alias=${alias}  detailed_dependent_equipment_dict=${detailed_dependent_equipment_dict}
    Get Site Reset Impact On peer BTS  peer_aliases=${peer_aliases}  TL_detailed_equipment_dict=${TL_detailed_equipment_dict}
    Get alarms during Site Reset on peer BTS  peer_aliases=${peer_aliases}
    ...  TL_detailed_equipment_dict=${TL_detailed_equipment_dict}

Select dependency rule and exceptions based on cb007447 status
    [Arguments]    ${cb007447_status}  ${CB007447_EXCEPTIONS}

    ${dependency_rules_dict_name}=  Set Variable If  ${cb007447_status}
    ...  Reset_dependency_rules_CB007447  Reset_dependency_rules
    ${dependency_rules_dict}=  Get Variable Value  ${${dependency_rules_dict_name}}

    ${exceptions}=  Set Variable If  ${cb007447_status}  ${CB007447_EXCEPTIONS}  &{Empty}
    RETURN    ${dependency_rules_dict}  ${exceptions}

Get Site Reset Impact On BTS
    [Arguments]    ${alias}  ${detailed_dependent_equipment_dict}

    ${expected_own_BTS_shared_CPRI_RMOD_for_CB012446_sn}=  Get Combined List From Dictionary
    ...  ${detailed_dependent_equipment_dict}
    ...  SHARED_RMOD_CPRI_enabled_SN  SHARED_RMOD_CPRI_disabled_SN
    ${expected_own_BTS_shared_CPRI_RMOD_for_CB012446_eligible}=  Get Combined List From Dictionary
    ...  ${detailed_dependent_equipment_dict}
    ...  SHARED_RMOD_CPRI_enabled_CB012446_eligible  SHARED_RMOD_CPRI_disabled_CB012446_eligible
    ${expected_own_BTS_shared_CPRI_RMOD_for_CB012446_connected_in}=  Get Combined List From Dictionary
    ...  ${detailed_dependent_equipment_dict}
    ...  SHARED_RMOD_CPRI_enabled_connected_in  SHARED_RMOD_CPRI_disabled_connected_in
    ${expected_own_BTS_shared_CPRI_RMOD_for_CB012446_not_connected_in_fhs}=
    ...  Evaluate  [x!='FHS' for x in ${expected_own_BTS_shared_CPRI_RMOD_for_CB012446_connected_in}]

    ${expected_own_BTS_shared_CPRI_RMOD_for_CB007447_eligible}=  Get Combined List From Dictionary
    ...  ${detailed_dependent_equipment_dict}
    ...  SHARED_RMOD_CPRI_enabled_CB007447_eligible  SHARED_RMOD_CPRI_disabled_CB007447_eligible
    ${expected_own_BTS_shared_CPRI_RMOD_for_CB007447_not_eligible}=
    ...  Evaluate  [not x for x in ${expected_own_BTS_shared_CPRI_RMOD_for_CB007447_eligible}]

    ${expected_own_BTS_shared_ECPRI_RMOD_for_CB012446_sn}=  Get Combined List From Dictionary
    ...  ${detailed_dependent_equipment_dict}
    ...  SHARED_RMOD_ECPRI_enabled_SN  SHARED_RMOD_ECPRI_disabled_SN
    ${expected_own_BTS_shared_ECPRI_RMOD_for_CB012446_eligible}=  Get Combined List From Dictionary
    ...  ${detailed_dependent_equipment_dict}
    ...  SHARED_RMOD_ECPRI_enabled_CB012446_eligible  SHARED_RMOD_ECPRI_disabled_CB012446_eligible
    ${expected_own_BTS_shared_ECPRI_RMOD_for_CB012446_connected_in}=  Get Combined List From Dictionary
    ...  ${detailed_dependent_equipment_dict}
    ...  SHARED_RMOD_ECPRI_enabled_connected_in  SHARED_RMOD_ECPRI_disabled_connected_in
    ${expected_own_BTS_shared_ECPRI_RMOD_for_CB012446_not_connected_in_fhs}=
    ...  Evaluate  [x!='FHS' for x in ${expected_own_BTS_shared_ECPRI_RMOD_for_CB012446_connected_in}]

    ${expected_own_BTS_shared_ECPRI_NETCONF_RMOD_for_CB012446_sn}=  Get Combined List From Dictionary
    ...  ${detailed_dependent_equipment_dict}
    ...  SHARED_RMOD_ECPRI_NETCONF_enabled_SN  SHARED_RMOD_ECPRI_NETCONF_disabled_SN
    ${expected_own_BTS_shared_ECPRI_NETCONF_RMOD_for_CB012446_eligible}=  Get Combined List From Dictionary
    ...  ${detailed_dependent_equipment_dict}
    ...  SHARED_RMOD_ECPRI_NETCONF_enabled_CB012446_eligible  SHARED_RMOD_ECPRI_NETCONF_disabled_CB012446_eligible
    ${expected_own_BTS_shared_ECPRI_NETCONF_RMOD_for_CB012446_connected_in}=  Get Combined List From Dictionary
    ...  ${detailed_dependent_equipment_dict}
    ...  SHARED_RMOD_ECPRI_NETCONF_enabled_connected_in  SHARED_RMOD_ECPRI_NETCONF_disabled_connected_in
    ${expected_own_BTS_shared_ECPRI_NETCONF_RMOD_for_CB012446_not_connected_in_fhs}=
    ...  Evaluate  [x!='FHS' for x in ${expected_own_BTS_shared_ECPRI_NETCONF_RMOD_for_CB012446_connected_in}]

    ${expected_own_BTS_dedicated_CPRI_RMOD_for_CB012446_sn}=  Get Combined List From Dictionary
    ...  ${detailed_dependent_equipment_dict}
    ...  DEDICATED_RMOD_CPRI_enabled_SN  DEDICATED_RMOD_CPRI_disabled_SN
    ${expected_own_BTS_dedicated_CPRI_RMOD_for_CB012446_eligible}=  Get Combined List From Dictionary
    ...  ${detailed_dependent_equipment_dict}
    ...  DEDICATED_RMOD_CPRI_enabled_CB012446_eligible  DEDICATED_RMOD_CPRI_disabled_CB012446_eligible
    ${expected_own_BTS_dedicated_CPRI_RMOD_for_CB012446_connected_in}=  Get Combined List From Dictionary
    ...  ${detailed_dependent_equipment_dict}
    ...  DEDICATED_RMOD_CPRI_enabled_connected_in  DEDICATED_RMOD_CPRI_disabled_connected_in
    ${expected_own_BTS_dedicated_CPRI_RMOD_for_CB012446_not_connected_in_fhs}=
    ...  Evaluate  [x!='FHS' for x in ${expected_own_BTS_dedicated_CPRI_RMOD_for_CB012446_connected_in}]

    ${expected_own_BTS_dedicated_ECPRI_RMOD_for_CB012446_sn}=  Get Combined List From Dictionary
    ...  ${detailed_dependent_equipment_dict}
    ...  DEDICATED_RMOD_ECPRI_enabled_SN  DEDICATED_RMOD_ECPRI_disabled_SN
    ${expected_own_BTS_dedicated_ECPRI_RMOD_for_CB012446_eligible}=  Get Combined List From Dictionary
    ...  ${detailed_dependent_equipment_dict}
    ...  DEDICATED_RMOD_ECPRI_enabled_CB012446_eligible  DEDICATED_RMOD_ECPRI_disabled_CB012446_eligible
    ${expected_own_BTS_dedicated_ECPRI_RMOD_for_CB012446_connected_in}=  Get Combined List From Dictionary
    ...  ${detailed_dependent_equipment_dict}
    ...  DEDICATED_RMOD_ECPRI_enabled_connected_in  DEDICATED_RMOD_ECPRI_disabled_connected_in
    ${expected_own_BTS_dedicated_ECPRI_RMOD_for_CB012446_not_connected_in_fhs}=
    ...  Evaluate  [x!='FHS' for x in ${expected_own_BTS_dedicated_ECPRI_RMOD_for_CB012446_connected_in}]

    ${expected_own_BTS_dedicated_ECPRI_NETCONF_RMOD_for_CB012446_sn}=  Get Combined List From Dictionary
    ...  ${detailed_dependent_equipment_dict}
    ...  DEDICATED_RMOD_ECPRI_NETCONF_enabled_SN  DEDICATED_RMOD_ECPRI_NETCONF_disabled_SN
    ${expected_own_BTS_dedicated_ECPRI_NETCONF_RMOD_for_CB012446_eligible}=  Get Combined List From Dictionary
    ...  ${detailed_dependent_equipment_dict}
    ...  DEDICATED_RMOD_ECPRI_NETCONF_enabled_CB012446_eligible  DEDICATED_RMOD_ECPRI_NETCONF_disabled_CB012446_eligible
    ${expected_own_BTS_dedicated_ECPRI_NETCONF_RMOD_for_CB012446_connected_in}=  Get Combined List From Dictionary
    ...  ${detailed_dependent_equipment_dict}
    ...  DEDICATED_RMOD_ECPRI_NETCONF_enabled_connected_in  DEDICATED_RMOD_ECPRI_NETCONF_disabled_connected_in
    ${expected_own_BTS_dedicated_ECPRI_NETCONF_RMOD_for_CB012446_not_connected_in_fhs}=
    ...  Evaluate  [x!='FHS' for x in ${expected_own_BTS_dedicated_ECPRI_NETCONF_RMOD_for_CB012446_connected_in}]

    ${expected_own_BTS_shared_CPRI_RMOD_supporting_CB012446_sn}=  Filter RMOD depending on feature
    ...  elements_to_be_filtered=${expected_own_BTS_shared_CPRI_RMOD_for_CB012446_sn}
    ...  list1_containing_filtering_criteria_flags=${expected_own_BTS_shared_CPRI_RMOD_for_CB012446_eligible}
    ...  list2_containing_filtering_criteria_flags=${expected_own_BTS_shared_CPRI_RMOD_for_CB012446_not_connected_in_fhs}
    IF  ${${alias}_CB007447_status}
        ${expected_own_BTS_shared_CPRI_RMOD_supporting_CB012446_no_CB007447_sn}=    Filter RMOD depending on feature
        ...  elements_to_be_filtered=${expected_own_BTS_shared_CPRI_RMOD_for_CB012446_sn}
        ...  list1_containing_filtering_criteria_flags=${expected_own_BTS_shared_CPRI_RMOD_for_CB012446_eligible}
        ...  list2_containing_filtering_criteria_flags=${expected_own_BTS_shared_CPRI_RMOD_for_CB007447_not_eligible}
        ...  list3_containing_filtering_criteria_flags=${expected_own_BTS_shared_CPRI_RMOD_for_CB012446_not_connected_in_fhs}
    ELSE
        ${expected_own_BTS_shared_CPRI_RMOD_supporting_CB012446_no_CB007447_sn}=    Filter RMOD depending on feature
        ...  elements_to_be_filtered=${expected_own_BTS_shared_CPRI_RMOD_for_CB012446_sn}
        ...  list1_containing_filtering_criteria_flags=${expected_own_BTS_shared_CPRI_RMOD_for_CB012446_eligible}
        ...  list2_containing_filtering_criteria_flags=${expected_own_BTS_shared_CPRI_RMOD_for_CB012446_not_connected_in_fhs}
    END
    ${expected_own_BTS_dedicated_CPRI_RMOD_supporting_CB012446_sn}=  Filter RMOD depending on feature
    ...  elements_to_be_filtered=${expected_own_BTS_dedicated_CPRI_RMOD_for_CB012446_sn}
    ...  list1_containing_filtering_criteria_flags=${expected_own_BTS_dedicated_CPRI_RMOD_for_CB012446_eligible}
    ...  list2_containing_filtering_criteria_flags=${expected_own_BTS_dedicated_CPRI_RMOD_for_CB012446_not_connected_in_fhs}
    ${expected_own_BTS_shared_ECPRI_RMOD_supporting_CB012446_sn}=  Filter RMOD depending on feature
    ...  elements_to_be_filtered=${expected_own_BTS_shared_ECPRI_RMOD_for_CB012446_sn}
    ...  list1_containing_filtering_criteria_flags=${expected_own_BTS_shared_ECPRI_RMOD_for_CB012446_eligible}
    ...  list2_containing_filtering_criteria_flags=${expected_own_BTS_shared_ECPRI_RMOD_for_CB012446_not_connected_in_fhs}
    ${expected_own_BTS_dedicated_ECPRI_RMOD_supporting_CB012446_sn}=  Filter RMOD depending on feature
    ...  elements_to_be_filtered=${expected_own_BTS_dedicated_ECPRI_RMOD_for_CB012446_sn}
    ...  list1_containing_filtering_criteria_flags=${expected_own_BTS_dedicated_ECPRI_RMOD_for_CB012446_eligible}
    ...  list2_containing_filtering_criteria_flags=${expected_own_BTS_dedicated_ECPRI_RMOD_for_CB012446_not_connected_in_fhs}
    ${expected_own_BTS_shared_ECPRI_NETCONF_RMOD_supporting_CB012446_sn}=  Filter RMOD depending on feature
    ...  elements_to_be_filtered=${expected_own_BTS_shared_ECPRI_NETCONF_RMOD_for_CB012446_sn}
    ...  list1_containing_filtering_criteria_flags=${expected_own_BTS_shared_ECPRI_NETCONF_RMOD_for_CB012446_eligible}
    ...  list2_containing_filtering_criteria_flags=${expected_own_BTS_shared_ECPRI_NETCONF_RMOD_for_CB012446_not_connected_in_fhs}
    ${expected_own_BTS_dedicated_ECPRI_NETCONF_RMOD_supporting_CB012446_sn}=  Filter RMOD depending on feature
    ...  elements_to_be_filtered=${expected_own_BTS_dedicated_ECPRI_NETCONF_RMOD_for_CB012446_sn}
    ...  list1_containing_filtering_criteria_flags=${expected_own_BTS_dedicated_ECPRI_NETCONF_RMOD_for_CB012446_eligible}
    ...  list2_containing_filtering_criteria_flags=${expected_own_BTS_dedicated_ECPRI_NETCONF_RMOD_for_CB012446_not_connected_in_fhs}

    Set Test Variable  ${own_BBMOD_shared_CPRI_RMOD_sn_list_012446}  ${expected_own_BTS_shared_CPRI_RMOD_supporting_CB012446_sn}
    Set Test Variable  ${own_BBMOD_enabled_shared_CPRI_RMOD_id_list_012446_no_007447}
    ...  ${expected_own_BTS_shared_CPRI_RMOD_supporting_CB012446_no_CB007447_sn}
    Set Test Variable  ${own_BBMOD_dedicated_CPRI_RMOD_sn_list_012446}  ${expected_own_BTS_dedicated_CPRI_RMOD_supporting_CB012446_sn}
    Set Test Variable  ${own_BBMOD_shared_ECPRI_RMOD_sn_list_012446}  ${expected_own_BTS_shared_ECPRI_RMOD_supporting_CB012446_sn}
    Set Test Variable  ${own_BBMOD_dedicated_ECPRI_RMOD_sn_list_012446}  ${expected_own_BTS_dedicated_ECPRI_RMOD_supporting_CB012446_sn}
    Set Test Variable  ${own_BBMOD_shared_ECPRI_NETCONF_RMOD_sn_list_012446}
    ...  ${expected_own_BTS_shared_ECPRI_NETCONF_RMOD_supporting_CB012446_sn}
    Set Test Variable  ${own_BBMOD_dedicated_ECPRI_NETCONF_RMOD_sn_list_012446}
    ...  ${expected_own_BTS_dedicated_ECPRI_NETCONF_RMOD_supporting_CB012446_sn}

    ${CB012446_shared_RMOD_sn_list}=  Combine Lists
    ...  ${own_BBMOD_shared_CPRI_RMOD_sn_list_012446}
    ...  ${own_BBMOD_shared_ECPRI_RMOD_sn_list_012446}
    ...  ${own_BBMOD_shared_ECPRI_NETCONF_RMOD_sn_list_012446}
    Set Test Variable  ${CB012446_shared_RMOD_sn_list}

Get Site Reset impact on peer BTS
    [Arguments]    ${peer_aliases}  ${TL_detailed_equipment_dict}

    FOR  ${peer_alias}  IN  @{peer_aliases}

        ${detailed_dependent_peer_equipment_dict}=  Get From Dictionary  ${TL_detailed_equipment_dict}  ${peer_alias}

        ${expected_peer_BTS_enabled_shared_RMOD_id_list}=  Get Combined List From Dictionary
        ...  ${detailed_dependent_peer_equipment_dict}
        ...  SHARED_RMOD_CPRI_enabled  SHARED_RMOD_ECPRI_enabled  SHARED_RMOD_ECPRI_NETCONF_enabled
        ...  SHARED_RMOD_OBSAI_enabled
        ${expected_peer_BTS_enabled_dedicated_RMOD_id_list}=  Get Combined List From Dictionary
        ...  ${detailed_dependent_peer_equipment_dict}
        ...  DEDICATED_RMOD_CPRI_enabled  DEDICATED_RMOD_ECPRI_enabled  DEDICATED_RMOD_ECPRI_NETCONF_enabled
        ...  DEDICATED_RMOD_OBSAI_enabled

        ${expected_peer_BTS_disabled_shared_RMOD_id_list}=  Get Combined List From Dictionary
        ...  ${detailed_dependent_peer_equipment_dict}
        ...  SHARED_RMOD_CPRI_disabled  SHARED_RMOD_ECPRI_disabled  SHARED_RMOD_ECPRI_NETCONF_disabled
        ...  SHARED_RMOD_OBSAI_disabled
        ${expected_peer_BTS_disabled_dedicated_RMOD_id_list}=  Get Combined List From Dictionary
        ...  ${detailed_dependent_peer_equipment_dict}
        ...  DEDICATED_RMOD_CPRI_disabled  DEDICATED_RMOD_ECPRI_disabled  DEDICATED_RMOD_ECPRI_NETCONF_disabled
        ...  DEDICATED_RMOD_OBSAI_disabled

        ${expected_peer_BTS_disabled_RMOD_id_list}=  Combine Lists
        ...  ${expected_peer_BTS_disabled_shared_RMOD_id_list}
        ...  ${expected_peer_BTS_disabled_dedicated_RMOD_id_list}

        ${expected_peer_BTS_enabled_shared_FHS_id_list}=  Get From Dictionary
        ...  ${detailed_dependent_peer_equipment_dict}
        ...  SHARED_FHS_CPRI_enabled
        ${expected_peer_BTS_disabled_shared_FHS_id_list}=  Get Combined List From Dictionary
        ...  ${detailed_dependent_peer_equipment_dict}
        ...  SHARED_FHS_CPRI_disabled

        ${expected_peer_BTS_shared_CPRI_RMOD_for_CB012446_sn}=  Get Combined List From Dictionary
        ...  ${detailed_dependent_peer_equipment_dict}
        ...  SHARED_RMOD_CPRI_enabled_SN  SHARED_RMOD_CPRI_disabled_SN
        ${expected_peer_BTS_shared_CPRI_RMOD_for_CB012446_eligible}=  Get Combined List From Dictionary
        ...  ${detailed_dependent_peer_equipment_dict}
        ...  SHARED_RMOD_CPRI_enabled_CB012446_eligible  SHARED_RMOD_CPRI_disabled_CB012446_eligible
        ${expected_peer_BTS_shared_CPRI_RMOD_for_CB012446_connected_in}=  Get Combined List From Dictionary
        ...  ${detailed_dependent_peer_equipment_dict}
        ...  SHARED_RMOD_CPRI_enabled_connected_in  SHARED_RMOD_CPRI_disabled_connected_in
        ${expected_peer_BTS_shared_CPRI_RMOD_for_CB012446_not_connected_in_fhs}=
        ...  Evaluate  [x!='FHS' for x in ${expected_peer_BTS_shared_CPRI_RMOD_for_CB012446_connected_in}]

        ${expected_peer_BTS_disabled_shared_CPRI_RMOD_for_CB007447_id}=  Get From Dictionary
        ...  ${detailed_dependent_peer_equipment_dict}
        ...  SHARED_RMOD_CPRI_disabled
        ${expected_peer_BTS_disabled_shared_CPRI_RMOD_for_CB007447_eligible_id}=  Get From Dictionary
        ...  ${detailed_dependent_peer_equipment_dict}
        ...  SHARED_RMOD_CPRI_disabled_CB007447_eligible
        ${expected_peer_BTS_disabled_shared_CPRI_RMOD_for_CB007447_not_eligible_id}=
        ...  Evaluate  [not x for x in ${expected_peer_BTS_disabled_shared_CPRI_RMOD_for_CB007447_eligible_id}]
        ${expected_peer_BTS_disabled_shared_CPRI_RMOD_for_CB007447_connected_in_id}=  Get Combined List From Dictionary
        ...  ${detailed_dependent_peer_equipment_dict}
        ...  SHARED_RMOD_CPRI_disabled_connected_in
        ${expected_peer_BTS_disabled_shared_CPRI_RMOD_for_CB007447_not_connected_in_id}=
        ...  Evaluate  [x!='FHS' for x in ${expected_peer_BTS_disabled_shared_CPRI_RMOD_for_CB007447_connected_in_id}]
        ${expected_peer_BTS_disabled_shared_CPRI_RMOD_connected_in_id}=
        ...  Evaluate  [x=='FHS' for x in ${expected_peer_BTS_disabled_shared_CPRI_RMOD_for_CB007447_connected_in_id}]

        ${expected_peer_BTS_shared_ECPRI_RMOD_for_CB012446_sn}=  Get Combined List From Dictionary
        ...  ${detailed_dependent_peer_equipment_dict}
        ...  SHARED_RMOD_ECPRI_enabled_SN  SHARED_RMOD_ECPRI_disabled_SN
        ${expected_peer_BTS_shared_ECPRI_RMOD_for_CB012446_eligible}=  Get Combined List From Dictionary
        ...  ${detailed_dependent_peer_equipment_dict}
        ...  SHARED_RMOD_ECPRI_enabled_CB012446_eligible  SHARED_RMOD_ECPRI_disabled_CB012446_eligible
        ${expected_peer_BTS_shared_ECPRI_RMOD_for_CB012446_connected_in}=  Get Combined List From Dictionary
        ...  ${detailed_dependent_peer_equipment_dict}
        ...  SHARED_RMOD_ECPRI_enabled_connected_in  SHARED_RMOD_ECPRI_disabled_connected_in
        ${expected_peer_BTS_shared_ECPRI_RMOD_for_CB012446_not_connected_in_fhs}=
        ...  Evaluate  [x!='FHS' for x in ${expected_peer_BTS_shared_ECPRI_RMOD_for_CB012446_connected_in}]

        ${expected_peer_BTS_shared_ECPRI_NETCONF_RMOD_for_CB012446_sn}=  Get Combined List From Dictionary
        ...  ${detailed_dependent_peer_equipment_dict}
        ...  SHARED_RMOD_ECPRI_NETCONF_enabled_SN  SHARED_RMOD_ECPRI_NETCONF_disabled_SN
        ${expected_peer_BTS_shared_ECPRI_NETCONF_RMOD_for_CB012446_eligible}=  Get Combined List From Dictionary
        ...  ${detailed_dependent_peer_equipment_dict}
        ...  SHARED_RMOD_ECPRI_NETCONF_enabled_CB012446_eligible  SHARED_RMOD_ECPRI_NETCONF_disabled_CB012446_eligible
        ${expected_peer_BTS_shared_ECPRI_NETCONF_RMOD_for_CB012446_connected_in}=  Get Combined List From Dictionary
        ...  ${detailed_dependent_peer_equipment_dict}
        ...  SHARED_RMOD_ECPRI_NETCONF_enabled_connected_in  SHARED_RMOD_ECPRI_NETCONF_disabled_connected_in
        ${expected_peer_BTS_shared_ECPRI_NETCONF_RMOD_for_CB012446_not_connected_in_fhs}=
        ...  Evaluate  [x!='FHS' for x in ${expected_peer_BTS_shared_ECPRI_NETCONF_RMOD_for_CB012446_connected_in}]

        ${expected_peer_BTS_dedicated_CPRI_RMOD_for_CB012446_sn}=  Get Combined List From Dictionary
        ...  ${detailed_dependent_peer_equipment_dict}
        ...  DEDICATED_RMOD_CPRI_enabled_SN  DEDICATED_RMOD_CPRI_disabled_SN
        ${expected_peer_BTS_dedicated_CPRI_RMOD_for_CB012446_eligible}=  Get Combined List From Dictionary
        ...  ${detailed_dependent_peer_equipment_dict}
        ...  DEDICATED_RMOD_CPRI_enabled_CB012446_eligible  DEDICATED_RMOD_CPRI_disabled_CB012446_eligible
        ${expected_peer_BTS_dedicated_CPRI_RMOD_for_CB012446_connected_in}=  Get Combined List From Dictionary
        ...  ${detailed_dependent_peer_equipment_dict}
        ...  DEDICATED_RMOD_CPRI_enabled_connected_in  DEDICATED_RMOD_CPRI_disabled_connected_in
        ${expected_peer_BTS_dedicated_CPRI_RMOD_for_CB012446_not_connected_in_fhs}=
        ...  Evaluate  [x!='FHS' for x in ${expected_peer_BTS_dedicated_CPRI_RMOD_for_CB012446_connected_in}]

        ${expected_peer_BTS_dedicated_ECPRI_RMOD_for_CB012446_sn}=  Get Combined List From Dictionary
        ...  ${detailed_dependent_peer_equipment_dict}
        ...  DEDICATED_RMOD_ECPRI_enabled_SN  DEDICATED_RMOD_ECPRI_disabled_SN
        ${expected_peer_BTS_dedicated_ECPRI_RMOD_for_CB012446_eligible}=  Get Combined List From Dictionary
        ...  ${detailed_dependent_peer_equipment_dict}
        ...  DEDICATED_RMOD_ECPRI_enabled_CB012446_eligible  DEDICATED_RMOD_ECPRI_disabled_CB012446_eligible
        ${expected_peer_BTS_dedicated_ECPRI_RMOD_for_CB012446_connected_in}=  Get Combined List From Dictionary
        ...  ${detailed_dependent_peer_equipment_dict}
        ...  DEDICATED_RMOD_ECPRI_enabled_connected_in  DEDICATED_RMOD_ECPRI_disabled_connected_in
        ${expected_peer_BTS_dedicated_ECPRI_RMOD_for_CB012446_not_connected_in_fhs}=
        ...  Evaluate  [x!='FHS' for x in ${expected_peer_BTS_dedicated_ECPRI_RMOD_for_CB012446_connected_in}]

        ${expected_peer_BTS_dedicated_ECPRI_NETCONF_RMOD_for_CB012446_sn}=  Get Combined List From Dictionary
        ...  ${detailed_dependent_peer_equipment_dict}
        ...  DEDICATED_RMOD_ECPRI_NETCONF_enabled_SN  DEDICATED_RMOD_ECPRI_NETCONF_disabled_SN
        ${expected_peer_BTS_dedicated_ECPRI_NETCONF_RMOD_for_CB012446_eligible}=  Get Combined List From Dictionary
        ...  ${detailed_dependent_peer_equipment_dict}
        ...  DEDICATED_RMOD_ECPRI_NETCONF_enabled_CB012446_eligible  DEDICATED_RMOD_ECPRI_NETCONF_disabled_CB012446_eligible
        ${expected_peer_BTS_dedicated_ECPRI_NETCONF_RMOD_for_CB012446_connected_in}=  Get Combined List From Dictionary
        ...  ${detailed_dependent_peer_equipment_dict}
        ...  DEDICATED_RMOD_ECPRI_NETCONF_enabled_connected_in  DEDICATED_RMOD_ECPRI_NETCONF_disabled_connected_in
        ${expected_peer_BTS_dedicated_ECPRI_NETCONF_RMOD_for_CB012446_not_connected_in_fhs}=
        ...  Evaluate  [x!='FHS' for x in ${expected_peer_BTS_dedicated_ECPRI_NETCONF_RMOD_for_CB012446_connected_in}]

        ${expected_peer_BTS_shared_CPRI_RMOD_supporting_CB012446_sn}=  Filter RMOD depending on feature
        ...  elements_to_be_filtered=${expected_peer_BTS_shared_CPRI_RMOD_for_CB012446_sn}
        ...  list1_containing_filtering_criteria_flags=${expected_peer_BTS_shared_CPRI_RMOD_for_CB012446_eligible}
        ...  list2_containing_filtering_criteria_flags=${expected_peer_BTS_shared_CPRI_RMOD_for_CB012446_not_connected_in_fhs}

        ${expected_peer_BTS_disabled_shared_CPRI_RMOD_supporting_CB007447_id}=  Filter RMOD depending on feature
        ...  elements_to_be_filtered=${expected_peer_BTS_disabled_shared_CPRI_RMOD_for_CB007447_id}
        ...  list1_containing_filtering_criteria_flags=${expected_peer_BTS_disabled_shared_CPRI_RMOD_for_CB007447_eligible_id}
        ...  list2_containing_filtering_criteria_flags=${expected_peer_BTS_disabled_shared_CPRI_RMOD_for_CB007447_not_connected_in_id}
        ${expected_peer_BTS_disabled_shared_CPRI_RMOD_not_supporting_CB007447_id}=  Filter RMOD depending on feature
        ...  elements_to_be_filtered=${expected_peer_BTS_disabled_shared_CPRI_RMOD_for_CB007447_id}
        ...  list1_containing_filtering_criteria_flags=${expected_peer_BTS_disabled_shared_CPRI_RMOD_for_CB007447_not_eligible_id}
        ...  list2_containing_filtering_criteria_flags=${expected_peer_BTS_disabled_shared_CPRI_RMOD_for_CB007447_not_connected_in_id}
        ${expected_peer_BTS_disabled_shared_CPRI_RMOD_connected_in_fhs_id}=  Filter RMOD depending on feature
        ...  elements_to_be_filtered=${expected_peer_BTS_disabled_shared_CPRI_RMOD_for_CB007447_id}
        ...  list1_containing_filtering_criteria_flags=${expected_peer_BTS_disabled_shared_CPRI_RMOD_connected_in_id}

        ${expected_peer_BTS_shared_ECPRI_RMOD_supporting_CB012446_sn}=  Filter RMOD depending on feature
        ...  elements_to_be_filtered=${expected_peer_BTS_shared_ECPRI_RMOD_for_CB012446_sn}
        ...  list1_containing_filtering_criteria_flags=${expected_peer_BTS_shared_ECPRI_RMOD_for_CB012446_eligible}
        ...  list2_containing_filtering_criteria_flags=${expected_peer_BTS_shared_ECPRI_RMOD_for_CB012446_not_connected_in_fhs}
        ${expected_peer_BTS_shared_ECPRI_NETCONF_RMOD_supporting_CB012446_sn}=  Filter RMOD depending on feature
        ...  elements_to_be_filtered=${expected_peer_BTS_shared_ECPRI_NETCONF_RMOD_for_CB012446_sn}
        ...  list1_containing_filtering_criteria_flags=${expected_peer_BTS_shared_ECPRI_NETCONF_RMOD_for_CB012446_eligible}
        ...  list2_containing_filtering_criteria_flags=${expected_peer_BTS_shared_ECPRI_NETCONF_RMOD_for_CB012446_not_connected_in_fhs}
        ${expected_peer_BTS_dedicated_CPRI_RMOD_supporting_CB012446_sn}=  Filter RMOD depending on feature
        ...  elements_to_be_filtered=${expected_peer_BTS_dedicated_CPRI_RMOD_for_CB012446_sn}
        ...  list1_containing_filtering_criteria_flags=${expected_peer_BTS_dedicated_CPRI_RMOD_for_CB012446_eligible}
        ...  list2_containing_filtering_criteria_flags=${expected_peer_BTS_dedicated_CPRI_RMOD_for_CB012446_not_connected_in_fhs}
        ${expected_peer_BTS_dedicated_ECPRI_RMOD_supporting_CB012446_sn}=  Filter RMOD depending on feature
        ...  elements_to_be_filtered=${expected_peer_BTS_dedicated_ECPRI_RMOD_for_CB012446_sn}
        ...  list1_containing_filtering_criteria_flags=${expected_peer_BTS_dedicated_ECPRI_RMOD_for_CB012446_eligible}
        ...  list2_containing_filtering_criteria_flags=${expected_peer_BTS_dedicated_ECPRI_RMOD_for_CB012446_not_connected_in_fhs}
        ${expected_peer_BTS_dedicated_ECPRI_NETCONF_RMOD_supporting_CB012446_sn}=  Filter RMOD depending on feature
        ...  elements_to_be_filtered=${expected_peer_BTS_dedicated_ECPRI_NETCONF_RMOD_for_CB012446_sn}
        ...  list1_containing_filtering_criteria_flags=${expected_peer_BTS_dedicated_ECPRI_NETCONF_RMOD_for_CB012446_eligible}
        ...  list2_containing_filtering_criteria_flags=${expected_peer_BTS_dedicated_ECPRI_NETCONF_RMOD_for_CB012446_not_connected_in_fhs}

        Set Test Variable  ${expected_${peer_alias}_enabled_shared_RMOD_id_list}  ${expected_peer_BTS_enabled_shared_RMOD_id_list}
        Set Test Variable  ${expected_${peer_alias}_disabled_shared_RMOD_id_list}  ${expected_peer_BTS_disabled_shared_RMOD_id_list}
        Set Test Variable  ${expected_${peer_alias}_disabled_RMOD_id_list}  ${expected_peer_BTS_disabled_RMOD_id_list}
        Set Test Variable  ${expected_${peer_alias}_enabled_dedicated_RMOD_id_list}  ${expected_peer_BTS_enabled_dedicated_RMOD_id_list}
        Set Test Variable  ${expected_${peer_alias}_disabled_dedicated_RMOD_id_list}  ${expected_peer_BTS_disabled_dedicated_RMOD_id_list}
        Set Test Variable  ${expected_${peer_alias}_enabled_shared_FHS_id_list}  ${expected_peer_BTS_enabled_shared_FHS_id_list}
        Set Test Variable  ${expected_${peer_alias}_disabled_shared_FHS_id_list}  ${expected_peer_BTS_disabled_shared_FHS_id_list}

        Set Test Variable  ${${peer_alias}_BBMOD_disabled_shared_CPRI_RMOD_id_list_007447}
        ...  ${expected_peer_BTS_disabled_shared_CPRI_RMOD_supporting_CB007447_id}
        Set Test Variable  ${${peer_alias}_BBMOD_disabled_shared_CPRI_RMOD_id_list_no_007447}
        ...  ${expected_peer_BTS_disabled_shared_CPRI_RMOD_not_supporting_CB007447_id}
        Set Test Variable  ${${peer_alias}_FHS_disabled_shared_CPRI_RMOD_id_list}
        ...  ${expected_peer_BTS_disabled_shared_CPRI_RMOD_connected_in_fhs_id}

        Set Test Variable  ${${peer_alias}_BBMOD_shared_CPRI_RMOD_sn_list_012446}  ${expected_peer_BTS_shared_CPRI_RMOD_supporting_CB012446_sn}
        Set Test Variable  ${${peer_alias}_dedicated_CPRI_RMOD_sn_list_012446}  ${expected_peer_BTS_dedicated_CPRI_RMOD_supporting_CB012446_sn}
        Set Test Variable  ${${peer_alias}_BBMOD_shared_ECPRI_RMOD_sn_list_012446}  ${expected_peer_BTS_shared_ECPRI_RMOD_supporting_CB012446_sn}
        Set Test Variable  ${${peer_alias}_dedicated_ECPRI_RMOD_sn_list_012446}  ${expected_peer_BTS_dedicated_ECPRI_RMOD_supporting_CB012446_sn}
        Set Test Variable  ${${peer_alias}_BBMOD_shared_ECPRI_NETCONF_RMOD_sn_list_012446}
        ...  ${expected_peer_BTS_shared_ECPRI_NETCONF_RMOD_supporting_CB012446_sn}
        Set Test Variable  ${${peer_alias}_dedicated_ECPRI_NETCONF_RMOD_sn_list_012446}
        ...  ${expected_peer_BTS_dedicated_ECPRI_NETCONF_RMOD_supporting_CB012446_sn}

    END

Get alarms during Site Reset on peer BTS
    [Arguments]    ${peer_aliases}  ${TL_detailed_equipment_dict}

    FOR  ${peer_alias}  IN  @{peer_aliases}

        ${detailed_dependent_peer_equipment_dict}=  Get From Dictionary  ${TL_detailed_equipment_dict}  ${peer_alias}
        ${peer_BTS_OBSAI_FID10_alarm_count}  ${peer_BTS_CPRI_FID10_1815_alarm_count}  ${peer_BTS_ECPRI_FID16_alarm_count}=  Get peer BTS alarms
        ...  ${detailed_dependent_peer_equipment_dict}  ${peer_alias}

        ${peer_SBTS_EXPECTED_ALARMS_10}=  Prepare expected alarms list  ${test_alarms_list['${peer_alias.upper()}_EXPECTED_ALARMS_10']}
        ...  ${peer_BTS_OBSAI_FID10_alarm_count}
        ${peer_SBTS_EXPECTED_ALARMS_10_1815}=  Prepare expected alarms list  ${test_alarms_list['${peer_alias.upper()}_EXPECTED_ALARMS_10_1815']}
        ...  ${peer_BTS_CPRI_FID10_1815_alarm_count}
        ${peer_SBTS_EXPECTED_ALARMS_16}=  Prepare expected alarms list  ${test_alarms_list['${peer_alias.upper()}_EXPECTED_ALARMS_16']}
        ...  ${peer_BTS_ECPRI_FID16_alarm_count}
        ${peer_SBTS_EXPECTED_ALARMS_10_1815_16}=  Combine Lists  ${peer_SBTS_EXPECTED_ALARMS_10}  ${peer_SBTS_EXPECTED_ALARMS_10_1815}
        ...  ${peer_SBTS_EXPECTED_ALARMS_16}
        Set Test Variable  ${${peer_alias}_OBSAI_FID10_alarm_count}  ${peer_BTS_OBSAI_FID10_alarm_count}
        Set Test Variable  ${${peer_alias}_CPRI_FID10_1815_alarm_count}  ${peer_BTS_CPRI_FID10_1815_alarm_count}
        Set Test Variable  ${${peer_alias}_ECPRI_FID16_alarm_count}  ${peer_BTS_ECPRI_FID16_alarm_count}
        Set Test Variable  ${${peer_alias}_EXPECTED_ALARMS_10_1815_16}  ${peer_SBTS_EXPECTED_ALARMS_10_1815_16}

    END

Get peer BTS alarms
    [Arguments]  ${detailed_dependent_peer_equipment_dict}  ${peer_alias}

    ${RMOD_OBSAI_list}=  Get Combined List From Dictionary  ${detailed_dependent_peer_equipment_dict}
    ...  SHARED_RMOD_OBSAI_disabled  DEDICATED_RMOD_OBSAI_disabled
    ${RMOD_ECPRI_ECPRI_NETCONF_list}=  Get Combined List From Dictionary  ${detailed_dependent_peer_equipment_dict}
    ...  SHARED_RMOD_ECPRI_disabled  DEDICATED_RMOD_ECPRI_disabled
    ...  SHARED_RMOD_ECPRI_NETCONF_disabled  DEDICATED_RMOD_ECPRI_NETCONF_disabled
    IF  ${${peer_alias}_CB007447_status}
        ${CPRI_RMOD_generating_FID10_1815_id_list}=    Combine Lists
        ...  ${${peer_alias}_BBMOD_disabled_shared_CPRI_RMOD_id_list_no_007447}
        ...  ${${peer_alias}_FHS_disabled_shared_CPRI_RMOD_id_list}
    ELSE
        ${CPRI_RMOD_generating_FID10_1815_id_list}=    Combine Lists
        ...  ${${peer_alias}_BBMOD_disabled_shared_CPRI_RMOD_id_list_007447}
        ...  ${${peer_alias}_BBMOD_disabled_shared_CPRI_RMOD_id_list_no_007447}
        ...  ${${peer_alias}_FHS_disabled_shared_CPRI_RMOD_id_list}
    END

    ${CPRI_RMOD_FID10_1815_alarm_count}=  Get Length  ${CPRI_RMOD_generating_FID10_1815_id_list}
    ${CPRI_FHS_FID10_alarm_count}=  Get Length  ${expected_${peer_alias}_disabled_shared_FHS_id_list}

    ${OBSAI_FID10_alarm_count}=  Get Length  ${RMOD_OBSAI_list}
    ${CPRI_FID10_1815_alarm_count}=  Evaluate  ${CPRI_RMOD_FID10_1815_alarm_count} + ${CPRI_FHS_FID10_alarm_count}
    ${ECPRI_FID16_alarm_count}=  Get Length  ${RMOD_ECPRI_ECPRI_NETCONF_list}

    FOR  ${item}  IN  @{RMOD_ECPRI_ECPRI_NETCONF_list}
        ${RMOD_param}=  Get Parameters For  class_name=RMOD  id_num=${item}  connection=${peer_alias}
        IF  not('${RMOD_param['productName']}' in ${RMOD_ECPRI_fid16_exceptions})    CONTINUE
        ${ECPRI_FID16_alarm_count}=  Evaluate  ${ECPRI_FID16_alarm_count} - ${1}
    END

    RETURN  ${OBSAI_FID10_alarm_count}  ${CPRI_FID10_1815_alarm_count}  ${ECPRI_FID16_alarm_count}

Get shared RMOD synchronisation info on both BTS
    [Arguments]  ${shared_RMOD_sn_list}

    ${CPRI_shared_RMOD_sn_BTS_alias_linkModeSynchronization_info_dict}=  Create Dictionary

     FOR  ${RMOD_sn}  IN  @{shared_RMOD_sn_list}

        ${BTS_alias_linkModeSynchronization_info_dict}  ${RMOD_interface}=  Get shared RMOD synchronisation info  ${RMOD_sn}

        IF  '${RMOD_interface}' == 'CPRI_RP1'
            Set To Dictionary  ${CPRI_shared_RMOD_sn_BTS_alias_linkModeSynchronization_info_dict}
            ...  ${RMOD_sn}  ${BTS_alias_linkModeSynchronization_info_dict}
        END

    END

    RETURN  ${CPRI_shared_RMOD_sn_BTS_alias_linkModeSynchronization_info_dict}

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

    RETURN  ${BTS_alias_linkModeSynchronization_info_dict}  ${RMOD_interface}

Check peer BTS alarms during BTS reset from ims
    [Arguments]  ${alias}  ${peer_aliases}  ${timestamp}

    Log  ***** Check the other BTS(s) status and alarms during "Reset Site" operation on ${alias} from ims *****  console=True

    FOR  ${other_alias}  IN  @{peer_aliases}

        ${IGNORED_ALARMS_FULL}=  Combine Lists  ${test_alarms_list['${other_alias.upper()}_IGNORED_ALARMS']}
        ...  ${test_alarms_list['${other_alias.upper()}_IGNORED_ALARMS_DURING_RESET_SITE']}

        Log  Check ${other_alias} alarms:  console=True
        IF  ${${other_alias}_OBSAI_FID10_alarm_count} > 0
            Log  ${other_alias} "No connection to Unit (10)" alarm, expected number: ${${other_alias}_OBSAI_FID10_alarm_count}
            ...  console=True
        END
        IF  ${${other_alias}_CPRI_FID10_1815_alarm_count} > 0
            Log Long String  ${other_alias} "No connection to Unit (10)" or "Not able to synchronize baseband bus (1815)" alarm,
            ...  expected number: ${${other_alias}_CPRI_FID10_1815_alarm_count}  console=True
        END
        IF  ${${other_alias}_ECPRI_FID16_alarm_count} > 0
            Log  ${other_alias} "Unit synchronization failed (16)" alarm, expected number: ${${other_alias}_ECPRI_FID16_alarm_count}
            ...  console=True
        END

        Get And Check Detailed IMS2 Alarms SOAM  alias=${other_alias}  start_timestamp=${timestamp}
        ...  expected_alarms=${${other_alias}_EXPECTED_ALARMS_10_1815_16}  ignored_alarms=${IGNORED_ALARMS_FULL}
        ...  critical_alarms=${test_alarms_list['${other_alias.upper()}_CRITICAL_ALARMS']}
        ...  only_unexpected_alarms_which_are_not_cleared=${True}
        ...  only_unexpected_alarms_of_same_id_and_number_with_expected_alarms=${False}
        ...  skip_check_if_empty_expected_alarms=${False}

        IF  ${${other_alias}_OBSAI_FID10_alarm_count} > 0
            Log  ${other_alias} "No connection to Unit (10)" alarm, found number: ${${other_alias}_OBSAI_FID10_alarm_count}, as expected!
            ...  console=True
        END
        IF  ${${other_alias}_CPRI_FID10_1815_alarm_count} > 0
            Log Long String  ${other_alias} "No connection to Unit (10)" or "Not able to synchronize baseband bus (1815)" alarm,
            ...  found number: ${${other_alias}_CPRI_FID10_1815_alarm_count}, as expected!  console=True
        END
        IF  ${${other_alias}_ECPRI_FID16_alarm_count} > 0
            Log  ${other_alias} "Unit synchronization failed (16)" alarm, found number: ${${other_alias}_ECPRI_FID16_alarm_count}, as expected!
            ...  console=True
        END
        Log  ${other_alias} site - expected, ignored and critical alarms checked  console=True
    END

Check BTS states and alarms after BTS reset
    [Arguments]  ${alias}

    Log  Check BTS ${alias} states and alarms after BTS ${alias} reset:  console=True

    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_initial}  ${BTS_MAX_WAIT_TIME}
    Admin Check BTS Procedural and Blocking states  ${OnAir_}  ${Unblocked_}  ${remained_MAX_WAIT_TIME}  ${alias}
    Log  BTS ${alias} status:\n - proceduralState: OnAir, blockingState: Unblocked  console=True

    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_initial}  ${BTS_MAX_WAIT_TIME}
    Assert Every  class_name=RMOD  parameters=${RMOD_state_enabled_check}  timeout=${remained_MAX_WAIT_TIME}  connection=${alias}
    Log  BTS ${alias} RMODs status:\n - ${RMOD_state_enabled}  console=True

    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_initial}  ${BTS_MAX_WAIT_TIME}
    Check cells availability status online  ${alias}  ${remained_MAX_WAIT_TIME}
    Log  BTS ${alias} cells status:\n - operationalState=Enabled, availabilityStatus=Online, blockingState=Unblocked  console=True

    Get and Check Alarms SOAM  alias=${alias}  expected_alarms=@{EMPTY}  ignored_alarms=${test_alarms_list['${alias.upper()}_IGNORED_ALARMS']}
    ...  critical_alarms=${test_alarms_list['${alias.upper()}_CRITICAL_ALARMS']}
    Log  BTS ${alias} site - expected, ignored and critical alarms checked  console=True

Check peer BTS states and alarms after BTS reset
    [Arguments]  ${alias}  ${peer_aliases}

    FOR  ${peer_alias}  IN  @{peer_aliases}

        Log  Check BTS ${peer_alias} states and alarms after BTS ${alias} reset:  console=True

        Admin Check BTS Procedural and Blocking states  ${OnAir_}  ${Unblocked_}  ${BTS_MAX_WAIT_TIME}  ${peer_alias}
        Log  BTS ${peer_alias} status:\n - proceduralState: OnAir, blockingState: Unblocked  console=True

        Assert Every  class_name=RMOD  parameters=${RMOD_state_enabled_check}  timeout=${BTS_MAX_WAIT_TIME}  connection=${peer_alias}
        Log  BTS ${peer_alias} RMODs status:\n - ${RMOD_state_enabled}  console=True

        Check cells availability status online  ${peer_alias}  ${BTS_MAX_WAIT_TIME}
        Log  BTS ${peer_alias} cells status:\n - operationalState=Enabled, availabilityStatus=Online, blockingState=Unblocked  console=True

        Get and Check Alarms SOAM  alias=${peer_alias}  expected_alarms=@{EMPTY}
        ...  ignored_alarms=${test_alarms_list['${peer_alias.upper()}_IGNORED_ALARMS']}
        ...  critical_alarms=${test_alarms_list['${peer_alias.upper()}_CRITICAL_ALARMS']}
        Log  BTS ${peer_alias} site - expected, ignored and critical alarms checked  console=True

    END

Check all peer BTS CPRI shared RMODs status with CB007447 feature activated
    [Arguments]  ${date_timestamp_start_UTC}  ${date_timestamp_end_UTC}  ${peer_aliases}

    FOR  ${peer_alias}  IN  @{peer_aliases}

        IF  not ${${peer_alias}_CB007447_status}    CONTINUE

        Check peer BTS CPRI shared RMODs status with CB007447 feature activated
        ...  ${${peer_alias}_BBMOD_disabled_shared_CPRI_RMOD_id_list_007447}
        ...  ${date_timestamp_start_UTC}
        ...  ${date_timestamp_end_UTC}
        ...  ${peer_alias}

    END

Check peer BTS CPRI shared RMODs status with CB007447 feature activated
    [Arguments]  ${CPRI_shared_RMOD_id_list}  ${date_timestamp_start_UTC}  ${date_timestamp_end_UTC}  ${peer_alias}

    Log  Check BTS ${peer_alias} CPRI shared RMODs status with CB007447 feature activated:  console=True

    ${RMOD_status_dict}=  Create Dictionary  operationalState=enabled
    ${ims_file_path}=  Admin Collect IMS file with timestamp
    ...  folder_path=${Test Results Dir}/IMS/${peer_alias}  alias=${peer_alias}

    FOR  ${RMOD_id}  IN  @{CPRI_shared_RMOD_id_list}

        ${RMOD_param_list}=  Get Parameters For  class_name=RMOD  id_num=${RMOD_id}  connection=${peer_alias}
        ${RMOD_sn}=  Set Variable  ${RMOD_param_list['serialNumber']}

        IF  '${RMOD_sn}' in ${CB007447_shared_RM_sn_exceptions_list}    CONTINUE

        Check object parameters values are not changed from IMS file
        ...  ${ims_file_path}
        ...  ${RMOD_id}
        ...  ${RMOD_status_dict}
        ...  ${date_timestamp_start_UTC}
        ...  ${date_timestamp_end_UTC}

    END

    Log  BTS ${peer_alias} CPRI shared RMODs status with CB007447 feature activated as expected  console=True

Check all BTS reset behavior based on IMS info
    [Documentation]
    ...  BTS RESET info is checked based on IMS info. Reset behavior as expected if:
    ...  - BTS ${alias} site: 1
    ...  - other BTS(s) site: reset number is 0
    ...  Otherwise, reset behavior not as expected, then errors are added to report and failed.
    [Arguments]  ${alias}  ${peer_aliases}

    Log  Check all BTS reset behavior based on IMS info  console=True

    Get and check BTS RESET info from IMS file  expected_reset_number=1  alias=${alias}
    ...  start_point_timestamp_UTC=${date_timestamp_initial_UTC}  end_point_timestamp_UTC=${date_timestamp_final_UTC}

    FOR  ${other_alias}  IN  @{peer_aliases}

        Get and check BTS RESET info from IMS file  expected_reset_number=0  alias=${other_alias}
        ...  start_point_timestamp_UTC=${date_timestamp_initial_UTC}  end_point_timestamp_UTC=${date_timestamp_final_UTC}

    END

Check all BTS requested RMOD reset behavior based on Uptime info
    [Documentation]
    ...  Shared and dedicated RMOD RESET behavior is checked based on Uptime info get from BTS.
    ...  RMOD reset behavior as expected if:
    ...  - RMOD on all BTS: no reset if RU is eligible for CB012446 feature
    ...  Otherwise, reset behavior not as expected, then errors are added to report and failed.
    [Arguments]  ${alias}  ${peer_aliases}

    Log  Check all BTS requested RMOD reset behavior based on Uptime info  console=True

    ${BTS_alias_RMOD_sn_Uptime_dict_final}=  Get all BTS RMOD Uptime info
    Set Test Variable  ${BTS_alias_RMOD_sn_Uptime_dict_final}

    Log  Check BTS ${alias} shared RMOD eligible for CB012446 feature reset behavior based on Uptime info  console=True

    IF  ${CB012446_shared_RMOD_sn_list}
        Check RMOD reset behavior on BTS  RMOD_sn_list=${CB012446_shared_RMOD_sn_list}  alias=${alias}
    ELSE
        Log  No shared RMODs eligible for CB012446 feature on BTS ${alias}  console=True
    END

    Log  Check BTS ${alias} dedicated RMOD eligible for CB012446 feature reset behavior based on Uptime info  console=True

    ${CB012446_dedicated_RMOD_sn_list}=  Combine Lists
    ...  ${own_BBMOD_dedicated_CPRI_RMOD_sn_list_012446}  ${own_BBMOD_dedicated_ECPRI_RMOD_sn_list_012446}
    ...  ${own_BBMOD_dedicated_ECPRI_NETCONF_RMOD_sn_list_012446}

    IF  ${CB012446_dedicated_RMOD_sn_list}
        Check RMOD reset behavior on BTS  RMOD_sn_list=${CB012446_dedicated_RMOD_sn_list}  alias=${alias}
    ELSE
        Log  No dedicated RMODs eligible for CB012446 feature on BTS ${alias}  console=True
    END

    FOR  ${other_alias}  IN  @{peer_aliases}

        Log  Check BTS ${other_alias} shared RMODs eligible for CB012446 feature reset behavior based on Uptime info  console=True

        ${BTS_peer_CB012446_shared_RMOD_sn_list}=  Combine Lists
        ...  ${${other_alias}_BBMOD_shared_CPRI_RMOD_sn_list_012446}  ${${other_alias}_BBMOD_shared_ECPRI_RMOD_sn_list_012446}
        ...  ${${other_alias}_BBMOD_shared_ECPRI_NETCONF_RMOD_sn_list_012446}

        IF  ${BTS_peer_CB012446_shared_RMOD_sn_list}
            Check RMOD reset behavior on BTS  RMOD_sn_list=${BTS_peer_CB012446_shared_RMOD_sn_list}  alias=${other_alias}
        ELSE
            Log  No shared RMODs eligible for CB012446 feature configured on BTS ${other_alias}  console=True
        END

        Log  Check BTS ${other_alias} dedicated RMODs reset behavior based on Uptime info  console=True

        ${BTS_peer_CB012446_dedicated_RMOD_sn_list}=  Combine Lists
        ...  ${${other_alias}_dedicated_CPRI_RMOD_sn_list_012446}  ${${other_alias}_dedicated_ECPRI_RMOD_sn_list_012446}
        ...  ${${other_alias}_dedicated_ECPRI_NETCONF_RMOD_sn_list_012446}

        IF  ${BTS_peer_CB012446_dedicated_RMOD_sn_list}
            Check RMOD reset behavior on BTS  RMOD_sn_list=${BTS_peer_CB012446_dedicated_RMOD_sn_list}  alias=${other_alias}
        ELSE
            Log  No dedicated RMODs configured on BTS ${other_alias}  console=True
        END

    END

    IF  ${own_BBMOD_enabled_shared_CPRI_RMOD_id_list_012446_no_007447}
        Log  Get Primary Link status (linkModeSynchronization) for shared RMODs eligible for CB012446:  console=True
    END
    IF  ${own_BBMOD_enabled_shared_CPRI_RMOD_id_list_012446_no_007447}
        ${CPRI_CB012446_shared_RMOD_sn_BTS_alias_linkModeSynchronization_info_dict_final}=
        ...  Get shared RMOD synchronisation info on both BTS
        ...  shared_RMOD_sn_list=${own_BBMOD_enabled_shared_CPRI_RMOD_id_list_012446_no_007447}
    END

    IF  ${own_BBMOD_enabled_shared_CPRI_RMOD_id_list_012446_no_007447}
        ${CB012446_shared_RMOD_PL_check}=    Run Keyword And Return Status    Run Keywords
        ...  Log  Checking Primary Link status (linkModeSynchronization) for shared RMODs eligible for CB012446 with CB007447 exceptions:
        ...  console=True
        ...  AND    Dictionaries Should Be Equal
        ...  ${CPRI_CB012446_shared_RMOD_sn_BTS_alias_linkModeSynchronization_info_dict_initial}
        ...  ${CPRI_CB012446_shared_RMOD_sn_BTS_alias_linkModeSynchronization_info_dict_final}
    ELSE
        ${CB012446_shared_RMOD_PL_check}=    Set Variable    ${EMPTY}
    END

    IF  ${own_BBMOD_enabled_shared_CPRI_RMOD_id_list_012446_no_007447} and '${CB012446_shared_RMOD_PL_check}' == 'True'
        Log  No Primary Link switch for CPRI shared RMODs eligible for CB012446, as expected  console=True
    ELSE IF  ${own_BBMOD_enabled_shared_CPRI_RMOD_id_list_012446_no_007447} and '${CB012446_shared_RMOD_PL_check}' == 'False'
        Log  Primary Link switch for CPRI shared RMODs eligible for CB012446, failed  level=ERROR
        Fail  Primary Link switch for CPRI shared RMODs eligible for CB012446, failed
    END

Check RMOD reset behavior on BTS
    [Arguments]  ${RMOD_sn_list}  ${alias}

    ${RMOD_sn_Uptime_dict_initial}=  Get From Dictionary  ${BTS_alias_RMOD_sn_Uptime_dict_initial}  ${alias}
    ${RMOD_sn_Uptime_dict_final}=  Get From Dictionary  ${BTS_alias_RMOD_sn_Uptime_dict_final}  ${alias}

    Check RMODs RESET behavior based on Uptime info on BTS  RMOD_sn_list=${RMOD_sn_list}
    ...  RMOD_sn_Uptime_dict_initial=${RMOD_sn_Uptime_dict_initial}  RMOD_sn_Uptime_dict_final=${RMOD_sn_Uptime_dict_final}  alias=${alias}

Get and check KPI1f info from IMS file
    [Documentation]
    ...  Keyword used to get and check KPI1f info from IMS file

    [Arguments]  ${alias}  ${CYCLE}

    Log  Get and check KPI1f info related to reset BTS ${alias} for iteration ${CYCLE}  console=True

    ${BTS_label}=  Get Variable Value  ${BTS_alias_label_dict}[${alias}]  ${None}
    ${BTS_kpi}=  Get Variable Value  ${${BTS_label}_RESET_WRN_THR}  ${None}

    ${kpi_name_delta_dict}=  Get and check KPI info from IMS file  kpi_names=kpi1f  kpi_thresholds=${BTS_kpi}  alias=${alias}
    ...  start_point_timestamp_UTC=${date_timestamp_initial_UTC}  end_point_timestamp_UTC=${date_timestamp_final_UTC}
    ${kpi_delta_list}=  Get From Dictionary  ${kpi_name_delta_dict}  kpi1f

    Export KPI Results to File  alias=${alias}  obj=BTS  obj_type=SBTS  obj_id=${alias}
    ...  action_1=Reset Site without RU reset  kpi_reported_1=KPI_1f
    ...  event_value_1=${kpi_delta_list[0]}  cycle=${CYCLE}  source_info=ims

Recover initial settings for CB012446 feature
    [Documentation]
    ...  Keyword used to recover initial settings for CB012446 feature

    [Arguments]  ${alias}

    Log  Recover initial settings for CB012446 feature on BTS ${alias}  console=True
    ${cntrldResetMplaneBreakTimeSite_initial}=
    ...  Get From Dictionary  ${${alias}_BTS_CB012446_feature_dict}  cntrldResetMplaneBreakTimeSite
    Set classical BTS CB012446 feature parameter
    ...  cntrldResetMplaneBreakTimeSite  ${cntrldResetMplaneBreakTimeSite_initial}  ${alias}

Particular Teardown
    FOR  ${alias}  IN  @{alias_list}

        IF  not '${BTS_alias_label_dict}[${alias}]' in '${BTS_LIST_explicit}'    CONTINUE

        Recover initial settings for CB012446 feature  ${alias}

    END

    Export KPI results to File Global  kpi_log_file_name=KpiTimeInfo

TC Setup
    ${tech_preset_list}=  Create List  SBTS  SBTS
    Common Test Setup  preset_techs=${tech_preset_list}  common_sbts=${TRUE}
    ...  infomodelSetup=${FALSE}  newAlarmsFormat=${TRUE}

TC Teardown
    Common Test Teardown
