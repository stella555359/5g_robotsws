*** Settings ***
Documentation    TC__NR_SBTS__STATE__PrimaryController_SecondaryController_Site_Reset_from_WEBEM_with_sharedFHS_config
Variables    tc_variables/nr_sbts__state__primary_controller_secondary_controller_site_reset_from_WEBEM_with_sharedfhs_config_alarms_definitions.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${BTS_PRIMARY_LINK}              # BTS for primary link set before Reset Site, possible values: empty (no set required),
                                 # Master (Master set required) or Slave (Slave set required), default value: empty
                                 # set relevant on Master or Slave only for CPRI or E_CPRI protocol, for OBSAI protocol let by default value (empty)
${SET_PRIMARY_LINK_TIME}         720     # Maximum time in seconds to wait for Primary Link set on ${BTS_PRIMARY_LINK}, default value: 720
${SET_PRIMARY_LINK_PROCEDURE}    LANE    # Procedure for setting BTS_PRIMARY_LINK, possible values: BTS (BTS Reset), LANE (Lock Unlock SFP LANE)
${BTS_ROLE}  Primary                     # Specify on which BTS to perform power Reset Site operation, possible values:
                                         # Primary (primary controller set required)
                                         # Secondary (secondary controller set required)
                                         # default value: Primary
${REPEAT_COUNTER}             3          # Number of NR reset BTS operations, default value 3
${RESET_WRN_THR}           540        # Compared with the time spent between first cell down and last cell up.
                                         # If exceeds RESET_WRN_THR, test verdict passed with restriction and snapshot collected.
                                         # Default value: in accordance with KPI 1a specifications
${MAX_WAIT_TIME}           900        # Maximum time for wait of BTS OnAir (first cell up after reset). If this value is exceeded, test will fail
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

*** Keywords ***
TC__NR_SBTS__STATE__PrimaryController_SecondaryController_Site_Reset_from_WEBEM_with_sharedFHS_config
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-22717
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  NR-SBTS test case for Primary or Secondary Controller Reset Site, - x times sequence.
    ...  x - value of REPEAT_COUNTER parameter (default: 3)
    ...  The main steps performed for the test are:
    ...  - set if needed primary link on requested technology
    ...  - check initial state and alarms for both NR and SBTS technologies
    ...  - perform Reset BTS operation on Primary or Secondary Controller
    ...  - check final state and alarms for both NR and SBTS technologies
    ...  - check reset behavior on NR and SBTS based on IMS info
    ...  Pass criteria: Reset BTS operation works as expected, states and alarms are as expected
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 15.04.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-22717 - [5G][CNI76753]
    ...  NR_SBTS__STATE__SharedFHS_Primary_Secondary_Controller_Site_Reset_with_sharedFHS_primarylink_towards_Primary_Secondary_Controller
    ...  - 12.09.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23368 -
    ...  [Cloud][Pilot robotws][PyLibraries] Drop "hran-tools" library KWs used by RFS TCs
    ...  - 03.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23925 - [5G][TC review][NR-SBTS] Remove Cells "AdministrativeState" check in
    ...  all NR-SBTS robots
    ...  - 10.02.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24695 - [5G] Ignore alarms FID7107, AID7114 in NR_SBTS TC
    ...  - 07.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24882 -
    ...  [5G][Reset Number ims2] Update NR-SBTS  STATE +FHS scenarios to take reset number from ims2 - P2
    ...  - 17.10.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26162 -
    ...  [5G] LTE_Site_Reset_from_WEBEM_SharedFHS_mixed_OBSAI_CPRI - update for FID10
    ...  - 15.04.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27281 - [5G] ALL TESTS: Reduce the number of ssh connections in Hardware File
    ...  Removal mechanism + restore 1 time orig
    ...  - 18.04.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27211 -
    ...  [5G][DSS alarms]Add wait_for_alarm_clear because DSS alarms are not cleared in current timer - NR_SBTS
    ...  - 26.09.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28126 - [5G] CNI : 131510 - Classical - Part 1 - Graceful cell shutdown
    ...  - 14.04.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-27956 - [REFACTORING][ALARMS] Remove legacy SOAM alarms in Test_Cases and
    ...  Alarm Files NR_SBTS & SBTS_SBTS
    ...  - 24.10.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29823 -
    ...  Unify alarm list names in order alarm list to begin with upper case Alias - NR_SBTS
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...  .. image:: https://gitlabe1.ext.net.nokia.com/panda-docs/hran_doc/-/blob/master/testsuite/RFS_SOAM/
    ...  TAT-22717_NR_SBTS__STATE__Primary_Secondary_Controller_Site_Reset_from_WEBEM.png
    ...  TAT-26087 https://jiradc.ext.net.nokia.com/browse/TAT-26087

    Set Tags    CA-STATE    OWNER-bogdan.vinereanu@nokia.com    AUTHOR-horea.olar@nokia.com    PHASE-QT    SW-SBTS22R4

    Configure Hardware File
    Primary Link TC Parameter Check
    Step 1: Check initial all BTS state
    Step 2: Check initial all BTS alarms
    Step 3: Get shared FHS and RMOD info
    FOR  ${INDEX}  IN RANGE  1  ${REPEAT_COUNTER}+1
        Log  ==============================================================================  console=True
        Log  Start Cycle ${INDEX} of ${REPEAT_COUNTER}  console=True
        Log  ==============================================================================  console=True
        Step 4: Get BTS primary controller and BTS secondary controller role
        Step 5: Set shared Primary Link before ${BTS_ROLE} Reset Site operation
        Step 6: Reset ${BTS_ROLE} BTS and export results for iteration ${INDEX}
        Step 7: Check final all BTS state
        Step 8: Check final all BTS alarms
        Step 9: Check NR and SBTS reset behavior based on IMS info
        Step 10: Check final number and state of Cells and RMs
    END

    [Teardown]  Particular Teardown

Configure Hardware File
    Return From Keyword If  '${SWCONFIG_CHANGE_FLAG}' == 'False'
    FOR  ${alias}  IN  @{alias_list}
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
    END

Step ${index}: Check ${when} all BTS alarms
    [Documentation]
    ...  SBTS alarms are compared with values from expected, ignored and critical alarms lists. SBTS alarms are get
    ...  from Admin

    Log  Step ${index}: Check ${when} all BTS alarms  console=True
    FOR  ${alias}  IN  @{alias_list}
        Log  ***** Check ${when} BTS ${alias} alarms *****  console=True
        ${wait_for_alarm_clear}=  Set Variable If  '${when}' == 'final'  15 min  5 min
        Get and Check Alarms SOAM  alias=${alias}  expected_alarms=@{EMPTY}  ignored_alarms=${${alias.upper()}_IGNORED_ALARMS}
        ...  critical_alarms=${${alias.upper()}_CRITICAL_ALARMS}  wait_for_alarm_clear=${wait_for_alarm_clear}
        Log  BTS ${alias} site - expected, ignored and critical alarms checked  console=True
    END

Step ${index}: Check ${when} SBTS alarms
    [Documentation]
    ...  SBTS alarms are compared with values from expected, ignored and critical alarms lists. SBTS alarms are get
    ...  from admin

    Log  Step ${index}: Check ${when} SBTS alarms  console=True
    ${wait_for_alarm_clear}=  Set Variable If  '${when}' == 'final'  15 min  5 min
    Get and Check Alarms SOAM  alias=Slave  expected_alarms=@{EMPTY}  ignored_alarms=${SLAVE_IGNORED_ALARMS}
    ...  critical_alarms=${SLAVE_CRITICAL_ALARMS}  wait_for_alarm_clear=${wait_for_alarm_clear}
    Log  SBTS site - expected, ignored and critical alarms checked  console=True

Step ${index}: Get BTS primary controller and BTS secondary controller role
    Log  Step ${index}: Get BTS primary controller and BTS secondary controller role  console=True
    ${peer_BTS_ROLE}=  Set Variable If  '${BTS_ROLE}' == 'Primary'  Secondary  Primary
    Set Test Variable  ${peer_BTS_ROLE}

    Get BTS primary controller shared RMOD list  Master
    Get BTS primary controller shared RMOD list  Slave
    Get BTS secondary controller shared RMOD list  Master
    Get BTS secondary controller shared RMOD list  Slave

    ${BTS_secondary_controller}=  Set Variable If
    ...  ${Master_primary_controller_shared_RMOD_count} == 0  Master  ${Slave_primary_controller_shared_RMOD_count} == 0  Slave  BOTH
    ${BTS_primary_controller}=  Set Variable If  '${BTS_secondary_controller}' == 'Master'  Slave  '${BTS_secondary_controller}' == 'Slave'  Master
    ...  BOTH

    Set Test Variable  ${BTS_primary_controller}
    Set Test Variable  ${BTS_secondary_controller}

    Log  BTS primary controller role: ${BTS_primary_controller}  console=True
    Log  BTS secondary controller role: ${BTS_secondary_controller}  console=True

Step ${index}: Get shared FHS and RMOD Info
    [Documentation]
    ...  Get shared FHS Primary Link info

    Log  Step ${index}: Get shared FHS and RMOD Info  console=True
    ${Master_shared_FHS_list}  ${Slave_shared_FHS_list}  ${Master_dedicated_FHS_list}  ${Slave_dedicated_FHS_list}=
    ...  Admin Get shared and dedicated module list for Master and Slave  FHS  Master  Slave
    Log  Shared FHS on NR BTS: ${Master_shared_FHS_list}  console=True
    Log  Shared FHS on SBTS BTS: ${Slave_shared_FHS_list}  console=True
    ${Master_shared_FHS_count}=  Get Length  ${Master_shared_FHS_list}
    ${Slave_shared_FHS_count}=  Get Length  ${Slave_shared_FHS_list}
    Set Test Variable  ${Master_shared_FHS_list}
    Set Test Variable  ${Slave_shared_FHS_list}
    Set Test Variable  ${Master_shared_FHS_count}
    Set Test Variable  ${Slave_shared_FHS_count}

    ${Master_shared_RMOD_list}  ${Slave_shared_RMOD_list}  ${Master_dedicated_RMOD_list}  ${Slave_dedicated_RMOD_list}=
    ...  Admin Get shared and dedicated module list for Master and Slave  RMOD  Master  Slave
    Set Test Variable  ${Master_shared_RMOD_list}
    Set Test Variable  ${Slave_shared_RMOD_list}
    Set Test Variable  ${Master_dedicated_RMOD_list}
    Set Test Variable  ${Slave_dedicated_RMOD_list}
    ${Master_shared_FHS_RMOD_list}=  Get shared RMOD connected to shared FHS  ${Master_shared_FHS_list}  Master
    ${Slave_shared_FHS_RMOD_list}=  Get shared RMOD connected to shared FHS  ${Slave_shared_FHS_list}  Slave
    Log  Shared RMOD connected to shared FHS on NR BTS:: ${Master_shared_FHS_RMOD_list}  console=True
    Log  Shared RMOD connected to shared FHS on STBS BTS: ${Slave_shared_FHS_RMOD_list}  console=True
    ${Master_shared_FHS_RMOD_count}=  Get Length  ${Master_shared_FHS_RMOD_list}
    ${Slave_shared_FHS_RMOD_count}=  Get Length  ${Slave_shared_FHS_RMOD_list}
    Set Test Variable  ${Master_shared_FHS_RMOD_list}
    Set Test Variable  ${Slave_shared_FHS_RMOD_list}
    Set Test Variable  ${Master_shared_FHS_RMOD_count}
    Set Test Variable  ${Slave_shared_FHS_RMOD_count}

    ${Master_count}=  Evaluate  ${Master_shared_FHS_count} + ${Master_shared_FHS_RMOD_count}
    ${Slave_count}=  Evaluate  ${Slave_shared_FHS_count} + ${Slave_shared_FHS_RMOD_count}
    Set Test Variable  ${Master_count}
    Set Test Variable  ${Slave_count}

    ${Master_Primary_Link_shared_FHS_list}=  Create List
    ${Slave_Primary_Link_shared_FHS_list}=  Create List
    Set Test Variable  ${Master_Primary_Link_shared_FHS_count}  0
    Set Test Variable  ${Slave_Primary_Link_shared_FHS_count}  0
    ${Master_Primary_Link_dict}  ${Slave_Primary_Link_dict}=  Get Primary Link status based on linkModeSynchronization  FHS
    ${Master_keys}=  Get Dictionary Keys  ${Master_Primary_Link_dict}  False
    ${Slave_keys}=  Get Dictionary Keys  ${Slave_Primary_Link_dict}  False
    FOR  ${Master_key}  ${Slave_key}  IN ZIP  ${Master_keys}  ${Slave_keys}
        ${Master_value}=  Get From Dictionary  ${Master_Primary_Link_dict}  ${Master_key}
        ${Slave_value}=  Get From Dictionary  ${Slave_Primary_Link_dict}  ${Slave_key}
        Run Keyword If  'True' in '${Master_value}'
        ...  Append To List  ${Master_Primary_Link_shared_FHS_list}  ${Master_key}
        ...  ELSE IF  'True' in '${Slave_value}'
        ...  Append To List  ${Slave_Primary_Link_shared_FHS_list}  ${Slave_key}
    END
    ${Master_Primary_Link_shared_FHS_count}=  Get Length  ${Master_Primary_Link_shared_FHS_list}
    ${Slave_Primary_Link_shared_FHS_count}=  Get Length  ${Slave_Primary_Link_shared_FHS_list}
    Log  Shared FHS count with Primary Link configured on NR BTS: ${Master_Primary_Link_shared_FHS_count}  console=True
    Log  Shared FHS count with Primary Link configured on SBTS BTS: ${Slave_Primary_Link_shared_FHS_count}  console=True

    ${Master_Primary_Link_shared_FHS_RMOD_list}=  Get shared RMOD connected to shared FHS  ${Master_Primary_Link_shared_FHS_list}  Master
    ${Slave_Primary_Link_shared_FHS_RMOD_list}=  Get shared RMOD connected to shared FHS  ${Slave_Primary_Link_shared_FHS_list}  Slave
    ${Master_Primary_Link_shared_FHS_RMOD_count}=  Get Length  ${Master_Primary_Link_shared_FHS_RMOD_list}
    ${Slave_Primary_Link_shared_FHS_RMOD_count}=  Get Length  ${Slave_Primary_Link_shared_FHS_RMOD_list}
    Log  Shared RMOD count connected to shared FHS with Primary Link configured on NR BTS: ${Master_Primary_Link_shared_FHS_RMOD_count}
    ...  console=True
    Log  Shared RMOD count connected to shared FHS with Primary Link configured on SBTS BTS: ${Slave_Primary_Link_shared_FHS_RMOD_count}
    ...  console=True

    ${Master_Primary_Link_count}=  Evaluate  ${Master_Primary_Link_shared_FHS_count} + ${Master_Primary_Link_shared_FHS_RMOD_count}
    ${Slave_Primary_Link_count}=  Evaluate  ${Slave_Primary_Link_shared_FHS_count} + ${Slave_Primary_Link_shared_FHS_RMOD_count}
    Set Test Variable  ${Master_Primary_Link_count}
    Set Test Variable  ${Slave_Primary_Link_count}

    ${Master_shared_RMOD_CELL_list}=  Get RMOD CELL list  ${Master_shared_RMOD_list}  Master
    ${Master_dedicated_RMOD_CELL_list}=  Get RMOD CELL list  ${Master_dedicated_RMOD_list}  Master
    ${Slave_shared_RMOD_CELL_list}=  Get RMOD CELL list  ${Slave_shared_RMOD_list}  Slave
    ${Slave_dedicated_RMOD_CELL_list}=  Get RMOD CELL list  ${Slave_dedicated_RMOD_list}  Slave
    Set Test Variable  ${Master_shared_RMOD_CELL_list}
    Set Test Variable  ${Master_dedicated_RMOD_CELL_list}
    Set Test Variable  ${Slave_shared_RMOD_CELL_list}
    Set Test Variable  ${Slave_dedicated_RMOD_CELL_list}

    ${SBTS_LTE_CELL_shared_RM_list}=  Copy List  ${SBTS_LTE_CELL_ids}
    ${SBTS_WCDMA_CELL_shared_RM_list}=  Copy List  ${SBTS_WCDMA_CELL_ids}
    ${SBTS_GSM_CELL_shared_RM_list}=  Copy List  ${SBTS_GSM_CELL_ids}
    ${SBTS_LTE_CELL_dedicated_RM_list}=  Copy List  ${SBTS_LTE_CELL_ids}
    ${SBTS_WCDMA_CELL_dedicated_RM_list}=  Copy List  ${SBTS_WCDMA_CELL_ids}
    ${SBTS_GSM_CELL_dedicated_RM_list}=  Copy List  ${SBTS_GSM_CELL_ids}
    FOR  ${item}  IN  @{Slave_dedicated_RMOD_CELL_list}
        Remove Values From List  ${SBTS_LTE_CELL_shared_RM_list}  ${item}
        Remove Values From List  ${SBTS_WCDMA_CELL_shared_RM_list}  ${item}
        Remove Values From List  ${SBTS_GSM_CELL_shared_RM_list}  ${item}
    END
    FOR  ${item}  IN  @{Slave_shared_RMOD_CELL_list}
        Remove Values From List  ${SBTS_LTE_CELL_dedicated_RM_list}  ${item}
        Remove Values From List  ${SBTS_WCDMA_CELL_dedicated_RM_list}  ${item}
        Remove Values From List  ${SBTS_GSM_CELL_dedicated_RM_list}  ${item}
    END

    Set Test Variable  ${SBTS_LTE_CELL_shared_RM_list}
    Set Test Variable  ${SBTS_WCDMA_CELL_shared_RM_list}
    Set Test Variable  ${SBTS_GSM_CELL_shared_RM_list}
    Set Test Variable  ${SBTS_LTE_CELL_dedicated_RM_list}
    Set Test Variable  ${SBTS_WCDMA_CELL_dedicated_RM_list}
    Set Test Variable  ${SBTS_GSM_CELL_dedicated_RM_list}

Step ${index}: Set shared Primary Link before ${BTS_ROLE} Reset Site operation
    [Documentation]
    ...  Set shared Primary Link if needed

    Log  Step ${index}: Set shared Primary Link before ${BTS_ROLE} Site Reset operation  console=True
    Run Keyword If  '${BTS_PRIMARY_LINK}' == ''  Run Keywords
    ...  Log  ==================================================================================  console=True
    ...  AND  Log  ***** Test action will be performed with existing Primary Link configuration *****  console=True
    ...  AND  Log  ==================================================================================  console=True
    ...  AND  Return From Keyword
    ...  ELSE  Run Keywords
    ...  Log  =============================================================================  console=True
    ...  AND  Log  ***** Test action will be performed with Primary Link set on BTS ${BTS_PRIMARY_LINK} *****  console=True
    ...  AND  Log  =============================================================================  console=True
    Run Keyword If  '${BTS_PRIMARY_LINK}' in ['Master','Slave']  Run Keywords
    ...  Set Primary Link status based on linkModeSynchronization  module_type=FHS
    ...  procedure_for_Primary_Link_set=${SET_PRIMARY_LINK_PROCEDURE}  alias=${BTS_PRIMARY_LINK}  wait_for_Primary_Link_set=${SET_PRIMARY_LINK_TIME}
    ...  AND  Set Primary Link status based on linkModeSynchronization  module_type=RMOD
    ...  procedure_for_Primary_Link_set=${SET_PRIMARY_LINK_PROCEDURE}  alias=${BTS_PRIMARY_LINK}  wait_for_Primary_Link_set=${SET_PRIMARY_LINK_TIME}
    ...  ELSE  Run Keywords
    ...  Log  Please set one of following values for test argument \${BTS_PRIMARY_LINK}: Master or Slave  level=ERROR
    ...  AND  Fail  Improper value for argument!

Step ${index}: Reset ${BTS_ROLE} BTS and export results for iteration ${CYCLE}
    [Documentation]
    ...  Reset BTS procedure is launched on NR Master.

    [Timeout]  20 min
    Log  Step ${index}: Reset BTS ${BTS_ROLE} controller and export results for iteration ${CYCLE}  console=True
    ${reset_alias}=  Set Variable If  '${BTS_ROLE}' == 'Primary'  ${BTS_primary_controller}  ${BTS_secondary_controller}
    Set Test Variable  ${reset_alias}
    ${hostname}=  Set Variable If  '${reset_alias}' == 'Master'  ${MASTER['MASTER_TECH_IP_ADDRESS']}  ${SLAVE['SLAVE_TECH_IP_ADDRESS']}
    ${remote_host}=  Set Variable If  '${reset_alias}' == 'Master'  None  ${SLAVE['SLAVE_PC_IP_ADDRESS']}
    ${CELL_state_enabled_check}=  Set Variable  operationalState=${Enabled_}
    ${CELL_state_disabled_check}=  Set Variable  operationalState=${Disabled_}
    ${CELL_state_enabled}=  Set Variable  operationalState=Enabled
    ${CELL_state_disabled}=  Set Variable  operationalState=Disabled
    Run Keyword If  '${BTS_PRIMARY_LINK}' == ''  Check RMOD L3 Protocol  ${reset_alias}
    Log  Perform "Reset Site" operation on BTS ${BTS_ROLE} controller from Admin  console=True
    Get RESET timestamp info  start
    RFS Site Reset  connection=${reset_alias}  graceful_cell_shutdown=${GRACEFUL_CELL_SHUTDOWN}
    Wait For Target To Be Not Reachable TAF  hostname=${hostname}  timeout=300  remote_host=${remote_host}
    Get Current Time  initial
    Log  ${reset_alias} BTS reset_start_time is: ${time_initial}  console=True
    Sleep  10s
    Run Keyword If  '${BTS_PRIMARY_LINK}' in ['Master','Slave'] and '${reset_alias}' == 'Master'  Check SBTS state and alarms
    ...  ELSE IF  '${BTS_PRIMARY_LINK}' in ['Master','Slave']  Check NR BTS state and alarms

    Get Current Time  before_check
    ${before_check_elapsed_time}=  DateTime.Subtract Date from Date  ${time_before_check}  ${time_initial}  number
    ${first_cell_up_remained_time}=  BuiltIn.Evaluate  ${MAX_WAIT_TIME}-${before_check_elapsed_time}
    ${first_cell_up_remained_time}=  Set Variable If  ${first_cell_up_remained_time} <= 0  5  ${first_cell_up_remained_time}
    Admin Check BTS Procedural and Blocking states  ${OnAir_}  ${Unblocked_}  ${first_cell_up_remained_time}  ${reset_alias}
    Get Current Time  first_cell_up
    ${reset_elapsed_time}=  DateTime.Subtract Date From Date  ${time_first_cell_up}  ${time_initial}  number
    Export ResetTime Results  ${reset_alias}  ${BTS Files}/${reset_alias}/ResetTimeInfo.txt  reset_sm  ${BTS_ROLE}_primary_controller  ${CYCLE}
    ...  ${reset_elapsed_time}  ${EMPTY}
    ${last_cell_up_remained_time}=  BuiltIn.Evaluate  ${MAX_WAIT_TIME}-${reset_elapsed_time}
    ${last_cell_up_remained_time}=  Set Variable If  ${last_cell_up_remained_time} <= 0  5  ${last_cell_up_remained_time}
    Run Keyword If  '${reset_alias}' == 'Master'  Run Keywords
    ...  Check BTS item state  NR  NRCEL  ${Master_shared_RMOD_CELL_list}  ${CELL_state_enabled_check}  ${CELL_state_enabled}
    ...  ${last_cell_up_remained_time}  Master
    ...  AND  Check BTS item state  NR  NRCEL  ${Master_dedicated_RMOD_CELL_list}  ${CELL_state_enabled_check}  ${CELL_state_enabled}
    ...  ${last_cell_up_remained_time}  Master
    ...  ELSE  Run Keywords
    ...  Check SBTS CELLS state  shared  ${CELL_state_enabled_check}  ${CELL_state_enabled}  ${last_cell_up_remained_time}
    ...  AND  Check SBTS CELLS state  dedicated  ${CELL_state_enabled_check}  ${CELL_state_enabled}  ${last_cell_up_remained_time}
    Get Current Time  last_cell_up
    ${all_cells_up_elapsed_time}=  DateTime.Subtract Date From Date  ${time_last_cell_up}  ${time_initial}  number
    Add KPI Results in File  alias=${reset_alias}  kpi_reported=KPI_1a  kpi_log_file=${BTS Files}/${reset_alias}/ResetTimeInfo.txt
    ...  info=first_cell_down_to_last_cell_up  cycle=${CYCLE}  event_value=${all_cells_up_elapsed_time}
    Check KPI  ${all_cells_up_elapsed_time}  ${RESET_WRN_THR}

Step ${index}: Check NR and SBTS reset behavior based on IMS info
    [Documentation]
    ...  Check NR and SBTS reset behavior based on IMS info. Reset behavior as expected if:
    ...  - NR site: reset number is 1
    ...  - SBTS site: reset number is 0
    ...  Otherwise, reset behavior not as expected, then errors are added to report and failed.

    Log  Step ${index}: Check NR and SBTS reset behavior  console=True
    ${NR_Reset_Number}=  Set Variable If  '${reset_alias}' == 'Master'  1  0
    ${SBTS_Reset_Number}=  Set Variable If  '${reset_alias}' == 'Slave'  1  0
    Get RESET timestamp info  end
    Get and check BTS RESET info from IMS file  expected_reset_number=${NR_Reset_Number}  alias=Master  remove_ims_file=False
    ...  start_point_timestamp_UTC=${date_timestamp_start_UTC}  end_point_timestamp_UTC=${date_timestamp_end_UTC}
    Get and check BTS RESET info from IMS file  expected_reset_number=${SBTS_Reset_Number}  alias=Slave  remove_ims_file=False
    ...  start_point_timestamp_UTC=${date_timestamp_start_UTC}  end_point_timestamp_UTC=${date_timestamp_end_UTC}

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]
    ...  Following checks are performed:
    ...  - number of configured cells and radio modules in SCF are properly mapped on BTS running view ADMIN
    ...  - check cells states
    ...  - check radio modules states

    Log  Step ${index}: Check final number and state of Cells and RMs  console=True
    RFS Test Case Final Checks

Get RESET timestamp info
    [Arguments]  ${when}
    Get Current Date UTC info  ${when}
    Log  UTC ${when}_point_timestamp: ${date_timestamp_${when}_UTC}  console=True

Get BTS primary controller shared RMOD list
    [Arguments]  ${alias}
    ${BTS_primary_controller_RMOD_list}=  Get RMOD radioMaster info  alias=${alias}
    ${BTS_primary_controller_shared_RMOD_list}=  Create List
    FOR  ${item}  IN  @{BTS_primary_controller_RMOD_list}
       Run Keyword If  '${item}' in ${${alias}_shared_RMOD_list}
        ...  Append To List  ${BTS_primary_controller_shared_RMOD_list}  ${item}
    END
    Sort List  ${BTS_primary_controller_shared_RMOD_list}
    Set Test Variable  ${${alias}_primary_controller_shared_RMOD_list}  ${BTS_primary_controller_shared_RMOD_list}
    Log  BTS ${alias} configured as primary controller for: ${BTS_primary_controller_shared_RMOD_list}  console=True
    ${BTS_primary_controller_shared_RMOD_count}=  Get Length  ${BTS_primary_controller_shared_RMOD_list}
    Set Test Variable  ${${alias}_primary_controller_shared_RMOD_count}  ${BTS_primary_controller_shared_RMOD_count}

Get BTS secondary controller shared RMOD list
    [Arguments]  ${alias}
    ${BTS_secondary_controller_shared_RMOD_list}=  Copy List  ${${alias}_shared_RMOD_list}
    FOR  ${item}  IN  @{${alias}_primary_controller_shared_RMOD_list}
        Remove Values From List  ${BTS_secondary_controller_shared_RMOD_list}  ${item}
    END
    Set Test Variable  ${${alias}_secondary_controller_shared_RMOD_list}  ${BTS_secondary_controller_shared_RMOD_list}

Check RMOD L3 Protocol
    [Arguments]  ${alias}
    Set Test Variable  ${RMOD_L3Protocol}  None
    ${RMOD_L3Protocol_dict}=  Admin Get RMOD L3 Protocol Info  ${alias}
    ${RMOD_L3Protocol_values}=  Get Dictionary Values  ${RMOD_L3Protocol_dict}
    ${RMOD_L3Protocol_value}=  Remove Duplicates  ${RMOD_L3Protocol_values}
    Run Keyword If  len(${RMOD_L3Protocol_value}) == 1  Set Test Variable  ${RMOD_L3Protocol}  ${RMOD_L3Protocol_value[0]}
    ...  ELSE  Return From Keyword

Check NR BTS state and alarms
    ${RMOD_state_enabled_check}=  Set Variable  operationalState=${Enabled_}, administrativeState=${Unlocked_}
    ${RMOD_state_disabled_check}=  Set Variable  operationalState=${Disabled_}, availabilityStatus=${NotInstalled_}, administrativeState=${Unlocked_}
    ${RMOD_state_enabled}=  Set Variable  operationalState=Enabled, administrativeState=Unlocked
    ${RMOD_state_disabled}=  Set Variable  operationalState=Disabled, availabilityStatus=NotInstalled, administrativeState=Unlocked
    ${CELL_state_disabled_check}=  Set Variable  operationalState=${Disabled_}
    ${CELL_state_disabled}=  Set Variable  operationalState=Disabled
    ${MASTER_EXPECTED_ALARMS_10_full}=  Prepare expected alarms list  ${MASTER_EXPECTED_ALARMS_10}  ${Slave_Primary_Link_count}
    ${MASTER_EXPECTED_ALARMS_X2_full}=  Combine Lists  ${MASTER_EXPECTED_ALARMS_7300}  ${MASTER_EXPECTED_ALARMS_7319}  ${MASTER_EXPECTED_ALARMS_62003}
    ${MASTER_EXPECTED_ALARMS_full}=  Combine Lists  ${MASTER_EXPECTED_ALARMS_10_full}  ${MASTER_EXPECTED_ALARMS_X2_full}
    ${MASTER_IGNORED_ALARMS_full}=  Combine Lists  ${MASTER_IGNORED_ALARMS}  ${MASTER_IGNORED_ALARMS_AFTER_RESET}

    Run Keyword If  '${BTS_PRIMARY_LINK}' == 'Slave'  Run Keywords
    ...  Check FHS state  ${Master_shared_FHS_list}  ${Disabled_}  ${NotInstalled_}  ${Unlocked_}  Master
    ...  AND  Check BTS item state  NR  RMOD  ${Master_shared_FHS_RMOD_list}  ${RMOD_state_disabled_check}  ${RMOD_state_disabled}  180  Master
    ...  AND  Check BTS item state  NR  RMOD  ${Master_dedicated_RMOD_list}  ${RMOD_state_enabled_check}  ${RMOD_state_enabled}  180  Master
    ...  AND  Check BTS item state  NR  NRCEL  ${Master_shared_RMOD_CELL_list}  ${CELL_state_disabled_check}  ${CELL_state_disabled}  180  Master
    ...  AND  Check BTS item state  NR  NRCEL  ${Master_dedicated_RMOD_CELL_list}  ${CELL_state_disabled_check}  ${CELL_state_disabled}  180  Master
    ...  ELSE IF  '${BTS_PRIMARY_LINK}' == 'Master'  Run Keywords
    ...  Check FHS state  ${Master_shared_FHS_list}  ${Enabled_}  ${Online_}  ${Unlocked_}  Master
    ...  AND  Check BTS item state  NR  RMOD  ${Master_shared_FHS_RMOD_List}  ${RMOD_state_enabled_check}  ${RMOD_state_enabled}  180  Master
    ...  AND  Check BTS item state  NR  RMOD  ${Master_dedicated_RMOD_List}  ${RMOD_state_enabled_check}  ${RMOD_state_enabled}  180  Master
    ...  AND  Check BTS item state  NR  NRCEL  ${Master_shared_RMOD_CELL_list}  ${CELL_state_disabled_check}  ${CELL_state_disabled}  180  Master
    ...  AND  Check BTS item state  NR  NRCEL  ${Master_dedicated_RMOD_CELL_list}  ${CELL_state_disabled_check}  ${CELL_state_disabled}  180  Master

    Run Keyword If  '${BTS_PRIMARY_LINK}' == 'Master'  Run Keywords
    ...  Log  NR BTS "No X2 link available (7300)" alarm, expected number: 1  console=True
    ...  AND  Log  NR BTS "No X2 link available for a specific LTEENB (7319)" alarm, expected number: 1  console=True
    ...  AND  Log  NR BTS "Transport layer connection lost in XP interface (62003)" alarm, expected number: 1  console=True
    ...  AND  Get and Check Alarms SOAM  alias=Master  expected_alarms=${MASTER_EXPECTED_ALARMS_X2_full}
    ...  ignored_alarms=${MASTER_IGNORED_ALARMS_full}  critical_alarms=${MASTER_CRITICAL_ALARMS}
    ...  AND  Log  NR BTS "No X2 link available (7300)" alarm, found number: 1, as expected!  console=True
    ...  AND  Log  NR BTS "No X2 link available for a specific LTEENB (7319)" alarm, found number: 1, as expected!  console=True
    ...  AND  Log  NR BTS "Transport layer connection lost in XP interface (62003)" alarm, found number: 1  console=True
    ...  ELSE IF  '${BTS_PRIMARY_LINK}' == 'Slave'  Run Keywords
    ...  Log  NR BTS "No connection to Unit (10)" alarm, expected number: ${Slave_Primary_Link_count}  console=True
    ...  AND  Log  NR BTS "No X2 link available (7300)" alarm, expected number: 1  console=True
    ...  AND  Log  NR BTS "No X2 link available for a specific LTEENB (7319)" alarm, expected number: 1  console=True
    ...  AND  Get and Check Alarms SOAM  alias=Master  expected_alarms=${MASTER_EXPECTED_ALARMS_full}
    ...  ignored_alarms=${MASTER_IGNORED_ALARMS_full}  critical_alarms=${MASTER_CRITICAL_ALARMS}
    ...  AND  Log  NR BTS "No connection to Unit (10)" alarm, found number: ${Slave_Primary_Link_count}, as expected!  console=True
    ...  AND  Log  NR BTS "No X2 link available (7300)" alarm, found number: 1, as expected!  console=True
    ...  AND  Log  NR BTS "No X2 link available for a specific LTEENB (7319)" alarm, found number: 1, as expected!  console=True
    Log  NR BTS site - expected, ignored and critical alarms checked  console=True

Check SBTS state and alarms
    ${RMOD_state_enabled_check}=  Set Variable  operationalState=${Enabled_}, administrativeState=${Unlocked_}
    ${RMOD_state_disabled_check}=  Set Variable  operationalState=${Disabled_}, availabilityStatus=${NotInstalled_}, administrativeState=${Unlocked_}
    ${RMOD_state_enabled}=  Set Variable  operationalState=Enabled, administrativeState=Unlocked
    ${RMOD_state_disabled}=  Set Variable  operationalState=Disabled, availabilityStatus=NotInstalled, administrativeState=Unlocked
    ${CELL_state_enabled_check}=  Set Variable  operationalState=${Enabled_}
    ${CELL_state_disabled_check}=  Set Variable  operationalState=${Disabled_}
    ${CELL_state_enabled}=  Set Variable  operationalState=Enabled
    ${CELL_state_disabled}=  Set Variable  operationalState=Disabled
    ${SLAVE_EXPECTED_ALARMS_10_full}=  Prepare expected alarms list  ${SLAVE_EXPECTED_ALARMS_10}  ${Master_Primary_Link_count}
    ${SLAVE_EXPECTED_ALARMS_FULL}=  Run Keyword If  '${BTS_PRIMARY_LINK}' == 'Slave'  Set Variable  ${SLAVE_EXPECTED_ALARMS_62003}
    ...  Combine Lists  ${SLAVE_EXPECTED_ALARMS_62003}  ${SLAVE_EXPECTED_ALARMS_10_full}

    Run Keyword If  '${BTS_PRIMARY_LINK}' == 'Master'  Run Keywords
    ...  Check FHS state  ${Slave_shared_FHS_list}  ${Disabled_}  ${NotInstalled_}  ${Unlocked_}
    ...  Slave
    ...  AND  Check BTS item state  SBTS  RMOD  ${Slave_shared_FHS_RMOD_list}  ${RMOD_state_disabled_check}  ${RMOD_state_disabled}  180  Slave
    ...  AND  Check BTS item state  SBTS  RMOD  ${Slave_dedicated_RMOD_list}  ${RMOD_state_enabled_check}  ${RMOD_state_enabled}  180  Slave
    ...  AND  Check SBTS CELLS state  shared  ${CELL_state_disabled_check}  ${CELL_state_disabled}  300
    ...  AND  Check SBTS CELLS state  dedicated  ${CELL_state_enabled_check}  ${CELL_state_enabled}  300
    ...  ELSE IF  '${BTS_PRIMARY_LINK}' == 'Slave'  Run Keywords
    ...  Check FHS state  ${Slave_shared_FHS_list}  ${Enabled_}  ${Online_}  ${Unlocked_}  Slave
    ...  AND  Check BTS item state  SBTS  RMOD  ${Slave_shared_FHS_RMOD_list}  ${RMOD_state_enabled_check}  ${RMOD_state_enabled}  180  Slave
    ...  AND  Check BTS item state  SBTS  RMOD  ${Slave_dedicated_RMOD_List}  ${RMOD_state_enabled_check}  ${RMOD_state_enabled}  180  Slave
    ...  AND  Check SBTS CELLS state  shared  ${CELL_state_enabled_check}  ${CELL_state_enabled}  300
    ...  AND  Check SBTS CELLS state  dedicated  ${CELL_state_enabled_check}  ${CELL_state_enabled}  300

    Run Keyword If  '${BTS_PRIMARY_LINK}' == 'Master'  Run Keywords
    ...  Log  SBTS BTS "No connection to Unit (10)" alarm, expected number: ${Master_Primary_Link_count}  console=True
    ...  AND  Get and Check Alarms SOAM  alias=Slave  expected_alarms=${SLAVE_EXPECTED_ALARMS_full}
    ...  ignored_alarms=${SLAVE_IGNORED_ALARMS}  critical_alarms=${SLAVE_CRITICAL_ALARMS}
    ...  AND  Log  SBTS BTS "No connection to Unit (10)" alarm, found number: ${Master_Primary_Link_count}, as expected!  console=True
    ...  AND  Log  SBTS BTS site - expected, ignored and critical alarms checked  console=True
    ...  ELSE IF  '${BTS_PRIMARY_LINK}' == 'Slave'  Run Keyword
    ...  Get and Check Alarms SOAM  alias=Slave  expected_alarms=${SLAVE_EXPECTED_ALARMS_full}
    ...  ignored_alarms=${SLAVE_IGNORED_ALARMS}  critical_alarms=${SLAVE_CRITICAL_ALARMS}

Get RMOD CELL list
    [Arguments]  ${RMOD_list}  ${alias}
    ${RMOD_CELL_list}=  Create List
    FOR  ${item}  IN  @{RMOD_list}
        ${CELL_list}=  Get Cell Mapping By Module Id  module_id=${item}  connection=${alias}
        Run Keyword If  ${CELL_list}  Append To List  ${RMOD_CELL_list}  @{CELL_list}
    END
    Remove Duplicates  ${RMOD_CELL_list}
    [Return]  ${RMOD_CELL_list}

Get shared RMOD connected to shared FHS
    [Arguments]  ${FHS_list}  ${alias}
    ${shared_FHS_RMOD_list}=  Create List
    FOR  ${item}  IN  @{FHS_list}
        ${RMOD_list}=  Get RMOD Mapping By FHS Id  ${item}  ${alias}
        Append To List  ${shared_FHS_RMOD_list}  @{RMOD_list}
    END
    ${shared_FHS_RMOD_list}=  Remove Duplicates  ${shared_FHS_RMOD_list}
    [Return]  ${shared_FHS_RMOD_list}

Get RMOD Mapping By FHS Id
    [Arguments]   ${FHS_id}  ${alias}
    ${RMOD_list}=  Create List
    ${CABLINK_list}=  Get Parameters For All  class_name=CABLINK  connection=${alias}
    FOR  ${item}  IN  @{CABLINK_list}
        ${CABLINK_id}=  Get From Dictionary  ${item}  id
        ${firstEndpointDN_FHS_R}=  Run Keyword And Return Status  Should Contain  ${item.firstEndpointDN}  FHS_R
        ${secondEndpointDN_RMOD_R}=  Run Keyword And Return Status  Should Contain  ${item.secondEndpointDN}  RMOD_R
        Run Keyword If  ${firstEndpointDN_FHS_R} and ${secondEndpointDN_RMOD_R}
        ...  Run Keyword If  '${item.firstEndpointDN}' == '${FHS_id}'
        ...  Append To List  ${RMOD_list}  ${item.secondEndpointDN}
    END
    ${RMOD_list}=  Remove Duplicates  ${RMOD_list}
    [Return]  ${RMOD_list}

Check BTS Item State
    [Arguments]   ${tech}  ${BTS_item_class}  ${BTS_item_list}  ${BTS_item_state_check}  ${BTS_item_state}  ${timeout}  ${alias}
    FOR  ${item}  IN  @{BTS_item_list}
        Assert  class_name=${BTS_item_class}  id=${item}  parameters=${BTS_item_state_check}  timeout=${timeout}  connection=${alias}
        Log  ${tech} ${BTS_item_class} ${item} status:\n - ${BTS_item_state}  console=True
    END

Check FHS state
    [Arguments]  ${FHS_list}  ${exp_operationalState}  ${exp_availabilityStatus}  ${exp_administrativeState}  ${alias}
    FOR  ${FHS_id}  IN  @{FHS_list}
        Wait Until Keyword Succeeds  300 sec  10 sec  Admin Check FHS state  ${FHS_id}   ${exp_operationalState}  ${exp_availabilityStatus}
        ...  ${exp_administrativeState}  ${alias}
    END

Check SBTS CELLS state
    [Arguments]  ${RM_SHARING_INFO}  ${CELL_state_check}  ${CELL_state}  ${timeout}
    Run Keyword If  ${SBTS_LTE_CELL_${RM_SHARING_INFO}_RM_list}
    ...  Check BTS Item State  SBTS  LNCEL  ${SBTS_LTE_CELL_${RM_SHARING_INFO}_RM_list}  ${CELL_state_check}  ${CELL_state}  ${timeout}  Slave
    Run Keyword If  ${SBTS_WCDMA_CELL_${RM_SHARING_INFO}_RM_list}
    ...  Check BTS Item State  SBTS  WNCEL  ${SBTS_WCDMA_CELL_${RM_SHARING_INFO}_RM_list}  ${CELL_state_check}  ${CELL_state}  ${timeout}  Slave
    Run Keyword If  ${SBTS_GSM_CELL_${RM_SHARING_INFO}_RM_list}
    ...  Check BTS Item State  SBTS  GNCEL  ${SBTS_GSM_CELL_${RM_SHARING_INFO}_RM_list}  ${CELL_state_check}  ${CELL_state}  ${timeout}  Slave

Hardware File Teardown
    Return From Keyword If  '${SWCONFIG_CHANGE_FLAG}' == 'False'
    FOR  ${alias}  IN  @{alias_list}
        Recover HWF Flags  alias=${alias}
    END

Particular Teardown
    Export ResetTime Results Global
    Hardware File Teardown

TC Setup
    ${tech_preset_list}=  Create List  SBTS  SBTS
    Common Test Setup  preset_techs=${tech_preset_list}  common_sbts=${TRUE}  infomodelSetup=${FALSE}

TC Teardown
    Common Test Teardown
