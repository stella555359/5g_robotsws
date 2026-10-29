*** Settings ***
Documentation    TC__NRL__STATE__LTE_Site_Reset_from_WEBEM_fALU_RMs
Variables    tc_variables/nrl__state__lte_site_reset_from_webem_falu_rms_alarms_definitions.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${BTS_PRIMARY_LINK}                       # BTS primary link set before LTE Site Reset, possible values: empty (no set required),
                                          # Master (Master set required) or Slave (Slave set required); default value: empty
${SET_PRIMARY_LINK_TIME}       720        # Maximum time in seconds to wait for Primary Link set on ${BTS_PRIMARY_LINK}, default value: 720
${SET_PRIMARY_LINK_PROCEDURE}  LANE       # Procedure for setting BTS_PRIMARY_LINK, possible values: BTS (BTS Reset), LANE (Lock Unlock SFP LANE)
${REPEAT_COUNTER}              3          # Number of LTE reset BTS operations, default value 3
${LTE_RESET_WRN_THR}           600        # If LTE Reset exceeds LTE_RESET_WRN_THR, test verdict will be failed and snapshot collected
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
TC__NRL__STATE__LTE_Site_Reset_from_WEBEM_fALU_RMs
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-17364
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
    ...  - 10.09.2019 - https://jiradc.ext.net.nokia.com/browse/TAT-17364 - [NR]Create new automated test NRL__STATE_LTE_Site_Reset_from WEBEM
    ...  - 14.10.2019 - https://jiradc.ext.net.nokia.com/browse/TAT-17835 - Primary CPRI enhancement
    ...  - 14.11.2019 - https://jiradc.ext.net.nokia.com/browse/TAT-18116 - CPRI primary set for TDD RM : robot TC enhancement
    ...  - 12.02.2020 - https://jiradc.ext.net.nokia.com/browse/TAT-18966 - Increase Timeout for Keywords related to Reset behaviour
    ...  - 13.02.2020 - https://jiradc.ext.net.nokia.com/browse/TAT-18907 - Move "Get Current Time " Keywords from Test cases to a common resource
    ...  - 17.02.2020 - https://jiradc.ext.net.nokia.com/browse/TAT-18983
    ...  - Check if parameter actCategoryAlarms is false/true for NRL__STATE__NR_RM_LockUnlock_from_WEBEM
    ...  - 05.06.2020 - https://jiradc.ext.net.nokia.com/browse/TAT-19638 - Check linkmodesynchronization parameter
    ...  - 23.07.2020 - https://jiradc.ext.net.nokia.com/browse/TAT-19956
    ...  - Refactor tests using "Set RMOD CPRI Primary Status" to provide Master/Slave argument to KW instead of NR/LTE
    ...  - 26.07.2020 - https://jiradc.ext.net.nokia.com/browse/TAT-19840 - Primary link check for CPRI-A RUs LTE/NR reset cases
    ...  - 09.09.2020 - https://jiradc.ext.net.nokia.com/browse/TAT-20150 - Additional checks for CPRI status
    ...  - 13.10.2020 - https://jiradc.ext.net.nokia.com/browse/TAT-20237 - Add CPRI primary link check functionality for new TDD RU AWHHF/D
    ...  - 21.10.2020 - https://jiradc.ext.net.nokia.com/browse/TAT-20324 - [Refactoring] Optimize Repeat_Counter loop in test cases - NRL
    ...  - 25.01.2021 - https://jiradc.ext.net.nokia.com/browse/TAT-20783 - [5G] ${fALU_RMOD_TYPE} parameter is not taken into account
    ...  - 25.02.2021 - https://jiradc.ext.net.nokia.com/browse/TAT-20503 - [Cloud] [NRL/SBTS] Cloud behavior Reset Time WRN threshold per Tech
    ...  - 25.02.2021 - https://jiradc.ext.net.nokia.com/browse/TAT-20503 - [Cloud] [NRL/SBTS] Cloud behavior Reset Time WRN threshold per Tech
    ...  - 18.03.2021 - https://jiradc.ext.net.nokia.com/browse/TAT-20864 - [Legacy] Pipeline: Clean up robot TC in RFS_SOAM folder - NRL
    ...  - 20.04.2021 - https://jiradc.ext.net.nokia.com/browse/TAT-21203 - [5G] ecPRI update for NRL__STATE__LTE_Site_Reset_from_WEBEM.robot
    ...  - 10.05.2021 - https://jiradc.ext.net.nokia.com/browse/TAT-21302 -
    ...  [Legacy][taf.sbts.oam.coam.admin] Update import in resources, update & test TC LG, MTNRL
    ...  - 03.09.2021 - https://jiradc.ext.net.nokia.com/browse/TAT-21804 - [5G] Refactoring due to stateInfo changes: NRL
    ...  - 24.11.2021 - https://jiradc.ext.net.nokia.com/browse/TAT-22115 -
    ...  [5G] Enhancement for TC NRL__STATE__LTE_Site_Reset_from_WEBEM: check eCPRI RMOD behaviour during peer reset
    ...  - 06.01.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-21775 - [5G][Legacy][RFSplit] Test NRL Common Part (hran_ta)
    ...  - 11.01.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-22359 - [5G][PrimaryLink] [P1] NRL: NR_SWDL, LTE_SWDL, LTE_Site_Reset refactor
    ...  to use 'hran_general.Set Primary Link status based on linkModeSynchronization' - w02
    ...  - 14.02.2021 - https://jiradc.ext.net.nokia.com/browse/TAT-22640 - [Cloud] [RFSplit] [Legacy] Particular teardown refactoring - NRL part
    ...  - 28.03.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-22747
    ...  [5G][PrimaryLink] Restore ${fALU_RMOD_TYPE} option for NRL__STATE__NR_Site_Reset_from_WEBEM, NRL__STATE__LTE_Site_Reset_from_WEBEM
    ...  - 08.04.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-22846
    ...  - [5G][HW file removal] Implement HW file removal in NRL_STATE_LTE_Site_Reset
    ...  - 12.09.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23368 -
    ...  [Cloud][Pilot robotws][PyLibraries] Drop "hran-tools" library KWs used by RFS TCs
    ...  - 20.09.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23736 - [5G] Rename
    ...  NRL__STATE__NR_Site_Reset_from_WEBEM & NRL__STATE__LTE_Site_Reset_from_WEBEM for formerALU module
    ...  - 12.01.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24426 - [5G]Update scenarios to take reset number from ims2 - NRL, Site_Reset,
    ...  fALU - with TAT-24370
    ...  - 12.01.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24370 - [5G] KPI1a: Update KPI calculation to use: taf.ul.oam_kpi_calculations -
    ...  NRL, Site_Reset, fALU - with TAT-24226
    ...  - 20.02.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24713 - [5G]Ignore alarm Fid7107, Aid7114 in NRL TCs, where there are alarm
    ...  checks done while LTE BTS is down
    ...  - 23.10.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26298 - [5G] Add proper description for HWF Feature.
    ...  - 08.11.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26303 - [5G] Introduce DSS alarm check in TCs - LTE Site Reset fALU
    ...  - 22.12.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26596 -
    ...  [5G][HW file removal] Update HW file removal mechanism in Site Reset fALU tests
    ...  - 07.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26549 - [5G] Update NRL__STATE__LTE_Site_Reset_from_WEBEM_fALU_RMs to detect
    ...  RMOD primary link and treat DSS alarms accordingly
    ...  - 12.04.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27210 - [5G][DSS alarms]Add wait_for_alarm_clear because DSS alarms are not
    ...  cleared in current timer - NRL
    ...  - 15.04.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27281 - [5G] ALL TESTS: Reduce the number of ssh connections in Hardware File
    ...  Removal mechanism + restore 1 time orig
    ...  - 26.09.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28126 - [5G] CNI : 131510 - Classical - Part 1 - Graceful cell shutdown
    ...  - 16.09.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29822 -
    ...  Unify alarm list names in order alarm list to begin with upper case Alias - NRL
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...  .. image:: https://gitlabe1.ext.net.nokia.com/panda-docs/hran_doc/-/blob/master/testsuite/RFS_SOAM/
    ...  TAT-17364_NRL__STATE__LTE_Site_Reset_from_WEBEM.png

    Set Tags    CA-STATE    OWNER-bogdan.vinereanu@nokia.com    AUTHOR-dinu.olariu@nokia.com    PHASE-QT    SW-5G19,SBTS19

    Primary Link TC Parameter Check
    Configure Hardware File
    Step 1: Check initial all BTS state
    Step 2: Check initial all BTS alarms
    Step 3: Get all RMOD info
    FOR  ${INDEX}  IN RANGE  1  ${REPEAT_COUNTER}+1
        Step 4: Set shared RMOD Primary Link before LTE Reset Site operation
        Step 5: Reset LTE BTS and export results for iteration ${INDEX}
        Step 6: Check final all BTS state
        Step 7: Check final all BTS alarms
        Step 8: Check NR and LTE reset behavior based on IMS info
        Step 9: Get and check KPI1a info from IMS file for iteration ${INDEX}
        Step 10: Check final number and state of Cells and RMs
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
    ...  AND  Return From Keyword
    ...  ELSE IF  '${BTS_PRIMARY_LINK}' in ['Master','Slave']  Run Keywords
    ...  Log  =============================================================================  console=True
    ...  AND  Log  ***** Test action will be performed with Primary Link set on BTS ${BTS_PRIMARY_LINK} *****  console=True
    ...  AND  Log  =============================================================================  console=True
    ...  AND  Set Primary Link status for shared RMOD  procedure_for_Primary_Link_set=${SET_PRIMARY_LINK_PROCEDURE}  alias=${BTS_PRIMARY_LINK}
    ...  wait_for_Primary_Link_set=${SET_PRIMARY_LINK_TIME}

Step ${index}: Reset LTE BTS and export results for iteration ${CYCLE}
    [Documentation]
    ...  Reset BTS procedure is launched on LTE Slave. Next script is waiting 300 sec for reset end

    [Timeout]  20 min
    Log  Step ${index}: Reset LTE BTS and export results for iteration ${CYCLE}  console=True
    Log  Perform "Reset Site" operation on LTE Slave from Admin  console=True
    Get Current Date UTC info  start
    RFS Site Reset  connection=Slave  graceful_cell_shutdown=${GRACEFUL_CELL_SHUTDOWN}
    Wait For Target To Be Not Reachable TAF  hostname=${SLAVE['SLAVE_TECH_IP_ADDRESS']}  timeout=300  remote_host=${SLAVE['SLAVE_PC_IP_ADDRESS']}
    Get Current Time  lte_initial
    Log  LTE reset_start_time is: ${time_lte_initial}  console=True
    Wait For Target To Be Reachable TAF  hostname=${SLAVE['SLAVE_TECH_IP_ADDRESS']}  timeout=300  remote_host=${SLAVE['SLAVE_PC_IP_ADDRESS']}
    Run Keyword If  '${BTS_PRIMARY_LINK}' in ['Master','Slave']  Check peer NR states and alarms
    Get Current Time  lte_final
    Log  LTE reset_end_time is: ${time_lte_final}  console=True
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_lte_initial}  ${LTE_MAX_WAIT_TIME}
    ${CELL_state_enabled_check}=  Set Variable  operationalState=${Enabled_}
    Assert Every  LNCEL  ${CELL_state_enabled_check}  timeout=${remained_MAX_WAIT_TIME}  alias=Slave
    Get Current Date UTC info  end

Step ${index}: Check NR and LTE reset behavior based on IMS info
    [Documentation]
    ...  RESET info is taken from IMS file for both NR and LTE. Reset behavior as expected if:
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
    Get NR cell list from shared RM

    ${Slave_shared_CPRI_RMOD_list}=  Create List
    ${Slave_shared_CPRI_ALU_RMOD_list}=  Create List
    ${Slave_RMOD_L3Protocol_dict}=  Admin Get RMOD L3 Protocol Info  Slave

    FOR  ${RMOD_id}  IN  @{Slave_shared_RM_list}
        ${RMOD_L3Protocol}=  Get From Dictionary  ${Slave_RMOD_L3Protocol_dict}  ${RMOD_id}
        Run Keyword If  '${RMOD_L3Protocol}' == 'CPRI_RP1'  Append To List  ${Slave_shared_CPRI_RMOD_list}  ${RMOD_id}
        ...  ELSE IF  '${RMOD_L3Protocol}' == 'CPRI_ALU'  Append To List  ${Slave_shared_CPRI_ALU_RMOD_list}  ${RMOD_id}
    END

    Set Test Variable  ${Slave_shared_CPRI_RMOD_list}
    Set Test Variable  ${Slave_shared_CPRI_ALU_RMOD_list}

    ${BTS_XP_localAlias_remoteAlias_dict}  ${NRBTS_DSS_alias_actLteNrDss_dict}  ${LNBTS_DSS_alias_actLteNrDss_dict}  ${BTS_DSS_NR_LTE_CELL_scf_dict}
    ...  ${BTS_DSS_LTE_NR_CELL_scf_dict}  ${BTS_DSS_NR_LTE_CELL_runtime_dict}  ${BTS_DSS_LTE_NR_CELL_runtime_dict}=  Get all BTS DSS feature info
    ${LNBTS_actLteNrDss}=  Get From Dictionary  ${LNBTS_DSS_alias_actLteNrDss_dict}  Slave
    Set Test Variable  ${LNBTS_actLteNrDss}
    Set Test Variable  ${BTS_DSS_LTE_NR_CELL_runtime_dict}

Get NR cell list from shared RM
    ${NR_CELL_RM_list}=  Create List
    FOR  ${item}  IN  @{Master_shared_RM_list}
        ${NR_CELL_RM_list_temp}=  Get Cell Mapping By Module Id  module_id=${item}  alias=Master
        Append To List  ${NR_CELL_RM_list}  @{NR_CELL_RM_list_temp}
    END
    ${NR_CELL_RM_list}=  Remove Duplicates  ${NR_CELL_RM_list}
    Set Test Variable  ${NR_CELL_RM_list}
    ${NR_CELL_RM_count}=  Get Length  ${NR_CELL_RM_list}
    Set Test Variable  ${NR_CELL_RM_count}

Check Cells State
    [Arguments]  ${CELL_class}  ${CELL_list}  ${states}  ${timeout}  ${alias}
    FOR  ${item}  IN  @{CELL_list}
        Assert  ${CELL_class}  ${item}  ${states}  timeout=${timeout}  alias=${alias}
    END

Check peer NR states and alarms
    ${CPRI_shared_RMOD_count}=  Get Length  ${Slave_shared_CPRI_RMOD_list}
    ${MASTER_EXPECTED_ALARMS_10_1815_full}=  Prepare expected alarms list  ${MASTER_EXPECTED_ALARMS_10_1815}  ${CPRI_shared_RMOD_count}
    ${MASTER_EXPECTED_ALARMS_full}=  Run Keyword If  '${BTS_PRIMARY_LINK}' == 'Master' and ${LNBTS_actLteNrDss}  Get NR DSS alarms
    ...  ELSE IF  '${BTS_PRIMARY_LINK}' == 'Slave'
    ...  Combine Lists  ${MASTER_EXPECTED_ALARMS_7319_7308}  ${MASTER_EXPECTED_ALARMS_7300}  ${MASTER_EXPECTED_ALARMS_10_1815_full}
    ...  ELSE  Create List

    ${MASTER_IGNORED_ALARMS_full}=  Combine Lists  ${MASTER_IGNORED_ALARMS_DURING_RESET_LTE}  ${MASTER_IGNORED_ALARMS_4764}  ${MASTER_IGNORED_ALARMS}
    Run Keyword If  '${BTS_PRIMARY_LINK}' == 'Slave'  Append To List  ${MASTER_IGNORED_ALARMS_full}  @{MASTER_EXPECTED_ALARMS_DSS}

    Run Keyword If  '${BTS_PRIMARY_LINK}' == 'Master'  Run Keywords
    ...  Check Cells State  NRCEL  ${NR_CELL_RM_list}  operationalState=${Enabled}  60  Master
    ...  AND  Log  NR cells are enabled  console=True
    ...  AND  Assert Every  RMOD  operationalState=${Enabled_}  timeout=60  alias=Master
    ...  AND  Log  All LTE RMOD - operationalState=Enabled  console=True

    Run Keyword If  '${BTS_PRIMARY_LINK}' == 'Slave'  Run Keywords
    ...  Log Long String  NR "Not able to synchronize baseband bus (1815) or No connection to unit (10)" alarm, expected number:
    ...  ${CPRI_shared_RMOD_count}  console=True
    ...  AND  Log  NR "No X2 link available (7300)" alarm, expected number: 1  console=True
    ...  AND  Log Long String  NR "No X2 link available for a specific LTEENB (7319)" or
    ...  "Transport layer connection failure in X2 interface (7308)" alarm, expected number: 1  console=True

    Run Keyword If  '${BTS_PRIMARY_LINK}' == 'Master' and ${LNBTS_actLteNrDss}
    ...  Log Long String  NR "EN DSS De-activated on partner side (7513)" or "EN DSS Keep Alive Procedure Time out (7511)" alarm or
    ...  "EN DSS Setup Failure - Max EN DSS Counter Value reached - No answer from CRM (7509)" alarm,
    ...  expected number: ${NR_DSS_alarm_count}  console=True

    Get and Check Alarms SOAM  alias=Master  expected_alarms=${${alias.upper()}_EXPECTED_ALARMS_full}
    ...  ignored_alarms=${${alias.upper()}_IGNORED_ALARMS_full}  critical_alarms=${${alias.upper()}_CRITICAL_ALARMS}

    Run Keyword If  '${BTS_PRIMARY_LINK}' == 'Slave'  Run Keywords
    ...  Log Long String  NR "Not able to synchronize baseband bus (1815) or No connection to unit (10)" alarm, found number:
    ...  ${CPRI_shared_RMOD_count}  console=True
    ...  AND  Log  NR "No X2 link available (7300)" alarm, found number: 1  console=True
    ...  AND  Log Long String  NR "No X2 link available for a specific LTEENB (7319)" or
    ...  "Transport layer connection failure in X2 interface (7308)" alarm, found number: 1  console=True

    Run Keyword If  '${BTS_PRIMARY_LINK}' == 'Master' and ${LNBTS_actLteNrDss}
    ...  Log Long String  NR "EN DSS De-activated on partner side (7513)" or "EN DSS Keep Alive Procedure Time out (7511)" alarm or
    ...  "EN DSS Setup Failure - Max EN DSS Counter Value reached - No answer from CRM (7509)" alarm,
    ...  found number: ${NR_DSS_alarm_count}, as expected!  console=True

    Log  NR site - expected, ignored and critical alarms checked  console=True

Get NR DSS alarms
    ${DSS_LTE_NR_CELL_runtime_dict}=  Get From Dictionary  ${BTS_DSS_LTE_NR_CELL_runtime_dict}  Slave
    ${NR_CELL_DSS_list}=  Get Dictionary Values  ${DSS_LTE_NR_CELL_runtime_dict}
    Set Test Variable  ${NR_CELL_DSS_list}
    ${NR_CELL_DSS_count}=  Get Length  ${NR_CELL_DSS_list}
    Set Test Variable  ${NR_DSS_alarm_count}  ${NR_CELL_DSS_count}
    ${MASTER_EXPECTED_ALARMS_DSS_full}=  Prepare expected alarms list  ${MASTER_EXPECTED_ALARMS_DSS}  ${NR_DSS_alarm_count}

    [Return]  ${MASTER_EXPECTED_ALARMS_DSS_full}

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
