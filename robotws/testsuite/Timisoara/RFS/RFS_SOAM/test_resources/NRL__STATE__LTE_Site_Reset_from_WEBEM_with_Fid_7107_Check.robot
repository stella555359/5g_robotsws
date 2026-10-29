*** Settings ***
Documentation    TC__NRL__STATE__LTE_Site_Reset_from_WEBEM_with_Fid_7107_Check
Variables    tc_variables/nrl__state__lte_site_reset_from_webem_with_fid_7107_check_alarms_definitions.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${BTS_PRIMARY_LINK}                       # BTS primary link set before LTE Site Reset, possible values: empty (no set required),
                                          # Master (Master set required) or Slave (Slave set required); default value: empty
${SET_PRIMARY_LINK_TIME}       720        # Maximum time in seconds to wait for Primary Link set on ${BTS_PRIMARY_LINK}, default value: 720
${SET_PRIMARY_LINK_PROCEDURE}  LANE       # Procedure for setting BTS_PRIMARY_LINK, possible values: BTS (BTS Reset), LANE (Lock Unlock SFP LANE)
${REPEAT_COUNTER}              3          # Number of LTE reset BTS operations, default value 3
${LTE_RESET_WRN_THR}           600        # Compared with the time spent between first cell down and last cell up.
                                          # If exceeds LTE_RESET_WRN_THR, test verdict will be failed and snapshot collected.
                                          # Default value: in accordance with KPI1a specifications
${LTE_MAX_WAIT_TIME}           900        # Maximum time for wait of BTS OnAir
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
TC__NRL__STATE__LTE_Site_Reset_from_WEBEM_with_Fid_7107_Check
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-24785
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  NR-LTE test case for LTE Reset Site, - x times sequence.
    ...  x - value of REPEAT_COUNTER parameter (default: 3)
    ...  The main steps performed for the test are:
    ...  - set if needed shared RMOD primary link on requested BTS
    ...  - check initial state and alarms for both NR and LTE technologies
    ...  - perform Reset BTS operation on LTE Slave
    ...  - check reset behavior on NR and LTE based on info from IMS file as follows:
    ...    - NR site: reset number is 0
    ...    - LTE site: reset number is 1
    ...  - check final state and alarms for both NR and LTE technologies
    ...  Pass criteria: LTE Reset BTS operation works as expected, states and alarms are as expected
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 07.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24785 -
    ...  [5G][CB007582] NRL__STATE__LTE_Site_Reset : FID7107 tested on NR after LTE Site reset (Primary Link on LTE BTS)
    ...  - 04.07.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25653 - [5G] Check of FID7509 to be included in NRL TestCases in checks on NR,
    ...  when LTE DSS partners are not available
    ...  - 27.07.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25675 - [5G] Use new DSS mechanism in existing TCs - NRL - Site reset,
    ...  SWDL, Power off on
    ...  - 23.10.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26298 - [5G] Add proper description for HWF Feature.
    ...  - 31.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26815 - [5G][HW file removal] Implement HW file removal in
    ...  NRL__STATE__LTE_Site_Reset_from_WEBEM_with_Fid_7107_Check
    ...  - 12.04.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27210 - [5G][DSS alarms]Add wait_for_alarm_clear because DSS alarms are not
    ...  cleared in current timer - NRL
    ...  - 15.04.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27281 - [5G] ALL TESTS: Reduce the number of ssh connections in Hardware File
    ...  Removal mechanism + restore 1 time orig
    ...  - 26.09.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28126 - [5G] CNI : 131510 - Classical - Part 1 - Graceful cell shutdown
    ...  - 17.04.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29018 - [REFACTORING][ALARMS] Remove legacy SOAM alarms in Test_Cases and
    ...  Alarm Files - NRL TCs
    ...  - 16.09.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29822 -
    ...  Unify alarm list names in order alarm list to begin with upper case Alias - NRL
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...  .. image:: https://gitlabe1.ext.net.nokia.com/panda-docs/hran_doc/-/blob/master/testsuite/
    ...  RFS_SOAM/TAT-24785_NRL__STATE__LTE_Site_Reset_from_WEBEM_with_Fid_7107_Check.png

    Set Tags    CA-STATE    OWNER-nicoleta.popescu@nokia.com    AUTHOR-traian-alin.bacos@nokia.com    PHASE-QT    SW-SBTS23

    Primary Link TC Parameter Check
    Configure Hardware File
    Step 1: Check initial all BTS state
    Step 2: Check initial all BTS alarms
    Step 3: Get all RMOD info
    FOR  ${INDEX}  IN RANGE  1  ${REPEAT_COUNTER}+1
        Log     ==============================================================================  console=True
        Log     Start Cycle ${INDEX} of ${REPEAT_COUNTER}  console=True
        Log     ==============================================================================  console=True
        Step 4: Set shared RMOD Primary Link before LTE Reset Site operation
        Step 5: Reset LTE BTS and export results for iteration ${INDEX}
        Step 6: Check final all BTS state
        Step 7: Check final all BTS alarms
        Step 8: Check final number and state of Cells and RMs
        Step 9: Check NR and LTE reset behavior based on IMS info
        Step 10: Get and check KPI1a info from IMS file for iteration ${INDEX}
    END

    [Teardown]  Particular Teardown

Configure Hardware File
    Return From Keyword If  '${SWCONFIG_CHANGE_FLAG}' == 'False'
    Set HWF Flags  swconfig_flag_action=${SWCONFIG_FLAG_ACTION}  swconfig_flag_list=${SWCONFIG_FLAG_LIST}  alias=Slave

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

Step ${index}: Set shared RMOD Primary Link before LTE Reset Site operation
    [Documentation]
    ...  Set shared RMOD Primary Link if needed

    Log  Step ${index}: Set shared RMOD Primary Link before LTE Reset Site operation  console=True

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
    END

Get ${when} RESET timestamp info
    Get Current Date UTC info  ${when}
    Log  UTC ${when}_point_timestamp: ${date_timestamp_${when}_UTC}  console=True

Step ${index}: Reset LTE BTS and export results for iteration ${CYCLE}
    [Documentation]
    ...  Reset BTS procedure is launched on LTE Slave. Next script is waiting 300 sec for reset end

    [Timeout]  20 min
    Log  Step ${index}: Reset LTE BTS and export results for iteration ${CYCLE}  console=True

    Get NR Cell Count

    ${BTS_XP_localAlias_remoteAlias_dict}  ${NRBTS_DSS_alias_actLteNrDss_dict}  ${LNBTS_DSS_alias_actLteNrDss_dict}  ${BTS_DSS_NR_LTE_CELL_scf_dict}
    ...  ${BTS_DSS_LTE_NR_CELL_scf_dict}  ${BTS_DSS_NR_LTE_CELL_runtime_dict}  ${BTS_DSS_LTE_NR_CELL_runtime_dict}=  Get all BTS DSS feature info
    Set Test Variable  ${BTS_DSS_LTE_NR_CELL_runtime_dict}

    ${LNBTS_actLteNrDss}=  Get From Dictionary  ${LNBTS_DSS_alias_actLteNrDss_dict}  Slave
    Set Test Variable  ${LNBTS_actLteNrDss}
    Run Keyword If  ${LNBTS_actLteNrDss}  Get NR DSS alarms

    ${CELL_state_enabled_check}=  Set Variable  operationalState=${Enabled_}, blockingState=${Unblocked_}

    Log  Perform "Reset Site" operation on LTE Slave from Admin  console=True
    Get start RESET timestamp info
    Get Current Time  lte_initial
    Log  LTE reset_start_time is: ${time_lte_initial}  console=True
    RFS Site Reset  connection=Slave  graceful_cell_shutdown=${GRACEFUL_CELL_SHUTDOWN}
    Wait For Target To Be Not Reachable TAF  hostname=${SLAVE['SLAVE_TECH_IP_ADDRESS']}  timeout=300  remote_host=${SLAVE['SLAVE_PC_IP_ADDRESS']}
    Check NR state and alarms during LTE site reset

    Get Current Time  lte_final
    ${elapsed_time}=  DateTime.Subtract Date from Date  ${time_lte_final}  ${time_lte_initial}  number
    ${remained_time}=  BuiltIn.Evaluate  ${LTE_MAX_WAIT_TIME} - ${elapsed_time}
    Assert Every  LNCEL  ${CELL_state_enabled_check}  timeout=${remained_time}  alias=Slave

Step ${index}: Check NR and LTE reset behavior based on IMS info
    [Documentation]
    ...  BTS RESET info is checked based on IMS info. Reset behavior as expected if:
    ...  - NR site: reset number is 0
    ...  - LTE site: reset number is 1
    ...  Otherwise, reset behavior not as expected, then errors are added to report and failed.

    Log  Step ${index}: Check NR and LTE reset behavior based on IMS info  console=True
    Get and check BTS RESET info from IMS file  expected_reset_number=0  alias=Master  remove_ims_file=False
    ...  start_point_timestamp_UTC=${date_timestamp_start_UTC}  end_point_timestamp_UTC=${date_timestamp_end_UTC}
    Get and check BTS RESET info from IMS file  expected_reset_number=1  alias=Slave  remove_ims_file=False
    ...  start_point_timestamp_UTC=${date_timestamp_start_UTC}  end_point_timestamp_UTC=${date_timestamp_end_UTC}

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]
    ...  Following checks are performed:
    ...  - number of configured cells and radio modules in SCF are properly mapped on BTS running view ADMIN
    ...  - check cells states
    ...  - check radio modules states

    Log  Step ${index}: Check final number and state of Cells and RMs  console=True
    RFS Test Case Final Checks
    Get end RESET timestamp info

Step ${index}: Get and check KPI1a info from IMS file for iteration ${CYCLE}
    [Documentation]
    ...  Get and check KPI1a info from IMS file.

    Log  Step ${index}: Get and check KPI1a info from IMS file for iteration ${CYCLE}  console=True
    ${kpi_name_delta_dict}=  Get and check KPI info from IMS file
    ...  kpi_names=kpi1a  kpi_thresholds=${LTE_RESET_WRN_THR}  alias=Slave  start_point_timestamp_UTC=${date_timestamp_start_UTC}
    ...  end_point_timestamp_UTC=${date_timestamp_end_UTC}
    ${kpi_delta_list}=  Get From Dictionary  ${kpi_name_delta_dict}  kpi1a

    Export KPI Results to File  alias=Slave  obj=BTS  obj_type=LTE  obj_id=Slave  action_1=Site_Reset  kpi_reported_1=KPI_1a
    ...  event_value_1=${kpi_delta_list[0]}  cycle=${CYCLE}  source_info=ims

Step ${index}: Get all RMOD info
    Log  Step ${index}: Get all RMOD info  console=True

    ${Master_shared_RM_list}  ${Slave_shared_RM_list}  ${Master_dedicated_RM_list}  ${Slave_dedicated_RM_list}=
    ...  Admin Get Shared And Dedicated RM List for Master and Slave  Master  Slave
    Sort List  ${Master_shared_RM_list}
    Sort List  ${Slave_shared_RM_list}
    Set Test Variable  ${Master_shared_RM_list}
    Set Test Variable  ${Slave_shared_RM_list}
    ${shared_RM_count}=  Get Length  ${Master_shared_RM_list}
    Set Test Variable  ${shared_RM_count}

Check NR state and alarms during LTE site reset
    ${RMOD_state_disabled_check}=  Set Variable
    ...  operationalState=${Disabled_}, availabilityStatus=${NotInstalled_Offline_}, administrativeState=${Unlocked_}
    ${RMOD_state_enabled_check}=  Set Variable  operationalState=${Enabled_}, administrativeState=${Unlocked_}
    ${RMOD_state_disabled}=  Set Variable  operationalState=Disabled, availabilityStatus=NotInstalled|Offline, administrativeState=Unlocked
    ${RMOD_state_enabled}=  Set Variable  operationalState=Enabled, administrativeState=Unlocked

    Run Keyword If  ${Master_non_PL_CPRI_shared_RMOD_list}  Run Keywords
    ...  Check BTS Item State  RMOD  ${Master_non_PL_CPRI_shared_RMOD_list}  ${RMOD_state_disabled_check}  60  Master
    ...  AND  Log  All CPRI Shared RMOD with Primary Link configured on LTE BTS status:\n - ${RMOD_state_disabled}  console=True
    Run Keyword If  ${Master_PL_CPRI_shared_RMOD_list}  Run Keywords
    ...  Check BTS Item State  RMOD  ${Master_PL_CPRI_shared_RMOD_list}  ${RMOD_state_enabled_check}  60  Master
    ...  AND  Log  All CPRI Shared RMOD with Primary Link configured on NR BTS status:\n - ${RMOD_state_enabled}  console=True
    Run Keyword If  ${Master_non_PL_ECPRI_shared_RMOD_list}  Run Keywords
    ...  Check BTS Item State  RMOD  ${Master_non_PL_ECPRI_shared_RMOD_list}  ${RMOD_state_disabled_check}  60  Master
    ...  AND  Log  All ECPRI Shared RMOD with Primary Link configured on LTE BTS status:\n - ${RMOD_state_disabled}  console=True
    Run Keyword If  ${Master_PL_ECPRI_shared_RMOD_list}  Run Keywords
    ...  Check BTS Item State  RMOD  ${Master_PL_ECPRI_shared_RMOD_list}  ${RMOD_state_enabled_check}  60  Master
    ...  AND  Log  All ECPRI Shared RMOD with Primary Link configured on NR BTS status:\n - ${RMOD_state_enabled}  console=True
    Run Keyword If  ${Master_non_PL_OBSAI_shared_RMOD_list}  Run Keywords
    ...  Check BTS Item State  RMOD  ${Master_non_PL_OBSAI_shared_RMOD_list}  ${RMOD_state_disabled_check}  60  Master
    ...  AND  Log  All OBSAI Shared RMOD with Primary Link configured on LTE BTS status:\n - ${RMOD_state_disabled}  console=True

    ${Slave_PL_CPRI_OBSAI_shared_RMOD_count}=  Evaluate  ${Slave_PL_CPRI_shared_RMOD_count} + ${Slave_PL_OBSAI_shared_RMOD_count}
    ${NR_non_PL_CPRI_OBSAI_shared_RM_CELL_count}=  Evaluate  ${NR_non_PL_CPRI_shared_RM_CELL_count} + ${NR_non_PL_OBSAI_shared_RM_CELL_count}
    ${MASTER_EXPECTED_ALARMS_DURING_RESET_multiplied}=  Prepare expected alarms list  ${MASTER_EXPECTED_ALARMS_DURING_RESET}
    ...  ${NR_shared_RM_CELL_COUNT}
    ${MASTER_EXPECTED_ALARMS_7107}=  Create List
    Append To List  ${MASTER_EXPECTED_ALARMS_7107}  @{MASTER_EXPECTED_ALARMS_DURING_RESET_multiplied}
    ${MASTER_EXPECTED_ALARMS_full}=  Create List
    Run Keyword If  ${LNBTS_actLteNrDss}  Append To List  ${MASTER_EXPECTED_ALARMS_full}  @{MASTER_EXPECTED_ALARMS_DSS_RESET_LTE_full}
    ${FID10_count}=  Set Variable  ${Slave_PL_CPRI_OBSAI_shared_RMOD_count}
    ${FID16_count}=  Set Variable If  ${Slave_PL_ECPRI_shared_RMOD_count}
    ${FID7107_count}=  Set Variable  ${NR_shared_RM_CELL_COUNT}
    ${MASTER_EXPECTED_ALARMS_10_full}=  Prepare expected alarms list  ${MASTER_EXPECTED_ALARMS_10}  ${FID10_count}
    ${MASTER_EXPECTED_ALARMS_16_full}=  Prepare expected alarms list  ${MASTER_EXPECTED_ALARMS_16}  ${FID16_count}
    ${MASTER_EXPECTED_ALARMS_10_16_full}=  Combine Lists  ${MASTER_EXPECTED_ALARMS_10_full}  ${MASTER_EXPECTED_ALARMS_16_full}
    ${MASTER_EXPECTED_ALARMS}=  Set Variable If  (${Slave_PL_CPRI_OBSAI_shared_RMOD_count} == 0 and ${Slave_PL_ECPRI_shared_RMOD_count} == 0)
    ...  ${MASTER_EXPECTED_ALARMS_full}  ${MASTER_EXPECTED_ALARMS_10_16_full}
    ${MASTER_IGNORED_ALARMS_full}=  Combine Lists  ${MASTER_IGNORED_ALARMS_DURING_RESET_LTE}  ${MASTER_IGNORED_ALARMS}

    Log Long String  NR "Cell problem due to associated X2 links and/or NG links and/or E1 link unavailability (7107)" alarm,
    ...  expected number: ${FID7107_count}  console=True
    Get and Check Alarms SOAM  alias=Master  expected_alarms=${MASTER_EXPECTED_ALARMS_7107}  ignored_alarms=${MASTER_IGNORED_ALARMS_full}
    ...  critical_alarms=${MASTER_CRITICAL_ALARMS}
    Log Long String  NR "Cell problem due to associated X2 links and/or NG links and/or E1 link unavailability (7107)" alarm,
    ...  found number: ${FID7107_count}, as expected!  console=True

    Run Keyword If  ${Slave_PL_CPRI_OBSAI_shared_RMOD_count} > 0
    ...  Log  NR "No connection to Unit (10)" alarm, expected number: ${FID10_count}  console=True
    Run Keyword If  ${Slave_PL_ECPRI_shared_RMOD_count} > 0
    ...  Log  NR "Unit synchronization failed (16)" alarm, expected number: ${FID16_count}  console=True
    Run Keyword If  ${LNBTS_actLteNrDss}
    ...  Log Long String  NR "EN DSS De-activated on partner side (7513)" or "EN DSS Keep Alive Procedure Time out (7511)" alarm or
    ...  "EN DSS Setup Failure - Max EN DSS Counter Value reached - No answer from CRM (7509)" alarm,
     ...  expected number: ${NR_DSS_RESET_LTE_alarm_count}  console=True

    Get and Check Alarms SOAM  alias=Master  expected_alarms=${MASTER_EXPECTED_ALARMS}  ignored_alarms=${MASTER_IGNORED_ALARMS_full}
    ...  critical_alarms=${MASTER_CRITICAL_ALARMS}

    Run Keyword If  ${Slave_PL_CPRI_OBSAI_shared_RMOD_count} > 0
    ...  Log  NR "No connection to Unit (10)" alarm, found number: ${FID10_count}, as expected!
    ...  console=True
    Run Keyword If  ${Slave_PL_ECPRI_shared_RMOD_count} > 0
    ...  Log  LTE "Unit synchronization failed (16)" alarm, found number: ${FID16_count}, as expected!
    ...  console=True
    Run Keyword If  ${LNBTS_actLteNrDss}
    ...  Log Long String  NR "EN DSS De-activated on partner side (7513)" or "EN DSS Keep Alive Procedure Time out (7511)" alarm or
    ...  "EN DSS Setup Failure - Max EN DSS Counter Value reached - No answer from CRM (7509)" alarm,
    ...  found number: ${NR_DSS_RESET_LTE_alarm_count}, as expected!  console=True

    Log  NR site - expected, ignored and critical alarms checked  console=True

Get cells mapped on shared RM
    [Arguments]  ${shared_RM_list}  ${alias}
    ${shared_RM_CELL_list}=  Create List
    FOR  ${item}  IN  @{shared_RM_list}
        ${CELL_RM_list}=  Get Cell Mapping By Module Id  module_id=${item}  alias=${alias}
        Append To List  ${shared_RM_CELL_list}  @{CELL_RM_list}
    END
    ${shared_RM_CELL_list}=  Remove Duplicates  ${shared_RM_CELL_list}
    ${shared_RM_CELL_count}=  Get Length  ${shared_RM_CELL_list}
    [Return]  ${shared_RM_CELL_list}  ${shared_RM_CELL_count}

Check BTS Item State
    [Arguments]  ${BTS_item_class}  ${BTS_item_list}  ${BTS_item_state_check}  ${timeout}  ${alias}
    FOR  ${item}  IN  @{BTS_item_list}
        Assert  class_name=${BTS_item_class}  id=${item}  parameters=${BTS_item_state_check}  timeout=${timeout}  connection=${alias}
    END

Get NR DSS alarms
    ${DSS_LTE_NR_CELL_runtime_dict}=  Get From Dictionary  ${BTS_DSS_LTE_NR_CELL_runtime_dict}  Slave
    ${NR_CELL_DSS_list}=  Get Dictionary Values  ${DSS_LTE_NR_CELL_runtime_dict}
    Set Test Variable  ${NR_CELL_DSS_list}
    ${LTE_NR_CELL_DSS_count}=  Get Length  ${DSS_LTE_NR_CELL_runtime_dict}
    Set Test Variable  ${NR_DSS_RESET_LTE_alarm_count}  ${LTE_NR_CELL_DSS_count}
    FOR  ${item}  IN  @{NR_CELL_DSS_list}
        ${NR_DSS_RESET_LTE_alarm_count}=  Run Keyword If  '${item}' in ${NR_non_PL_shared_RM_CELL_list}
        ...  Evaluate  ${NR_DSS_RESET_LTE_alarm_count} - 1
        ...  ELSE
        ...  Evaluate  ${NR_DSS_RESET_LTE_alarm_count} + 0
    END
    Set Test Variable  ${NR_DSS_RESET_LTE_alarm_count}
    ${MASTER_EXPECTED_ALARMS_DSS_RESET_LTE_full}=  Prepare expected alarms list  ${MASTER_EXPECTED_ALARMS_DSS}  ${NR_DSS_RESET_LTE_alarm_count}
    Set Test Variable  ${MASTER_EXPECTED_ALARMS_DSS_RESET_LTE_full}

Get NR Cell Count
    ${NR_non_PL_CPRI_shared_RM_CELL_list}  ${NR_non_PL_CPRI_shared_RM_CELL_count}=  Get cells mapped on shared RM
    ...  ${Master_non_PL_CPRI_shared_RMOD_list}  Master
    ${NR_non_PL_ECPRI_shared_RM_CELL_list}  ${NR_non_PL_ECPRI_shared_RM_CELL_count}=  Get cells mapped on shared RM
    ...  ${Master_non_PL_ECPRI_shared_RMOD_list}  Master
    ${NR_non_PL_OBSAI_shared_RM_CELL_list}  ${NR_non_PL_OBSAI_shared_RM_CELL_count}=  Get cells mapped on shared RM
    ...  ${Master_non_PL_OBSAI_shared_RMOD_list}  Master
    ${NR_shared_RM_CELL_list}  ${NR_shared_RM_CELL_COUNT}=  Get cells mapped on shared RM
    ...  ${Master_shared_RM_list}  Master
    ${NR_non_PL_shared_RM_CELL_list}=  Combine Lists  ${NR_non_PL_CPRI_shared_RM_CELL_list}  ${NR_non_PL_ECPRI_shared_RM_CELL_list}
    ...  ${NR_non_PL_OBSAI_shared_RM_CELL_list}
    Set Test Variable  ${NR_non_PL_CPRI_shared_RM_CELL_count}
    Set Test Variable  ${NR_non_PL_ECPRI_shared_RM_CELL_count}
    Set Test Variable  ${NR_non_PL_OBSAI_shared_RM_CELL_count}
    Set Test Variable  ${NR_shared_RM_CELL_COUNT}
    Set Test Variable  ${NR_non_PL_shared_RM_CELL_list}

Hardware File Teardown
    Return From Keyword If  '${SWCONFIG_CHANGE_FLAG}' == 'False'
    Recover HWF Flags  alias=Slave

Particular Teardown
    Export KPI results to File Global  kpi_log_file_name=KpiTimeInfo
    Hardware File Teardown

TC Setup
    ${tech_preset_list}=  Create List  SBTS  SBTS
    Common Test Setup  preset_techs=${tech_preset_list}  common_sbts=${TRUE}  infomodelSetup=${FALSE}

TC Teardown
    Common Test Teardown
