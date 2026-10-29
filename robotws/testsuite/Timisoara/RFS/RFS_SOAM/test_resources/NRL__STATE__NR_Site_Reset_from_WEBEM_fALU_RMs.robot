*** Settings ***
Documentation    TC__NRL__STATE__NR_Site_Reset_from_WEBEM_fALU_RMs
Variables    tc_variables/nrl__state__nr_site_reset_from_webem_falu_rms_alarms_definitions.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${REPEAT_COUNTER}  3  # Number of NR Reset Site operations, default value 3
${BTS_PRIMARY_LINK}  # BTS for primary link set before NR Reset Site, possible values: empty (no set required),
                     # Master (Master set required) or Slave (Slave set required), default value: empty
                     # set relevant on Master or Slave only for CPRI or E_CPRI protocol, for OBSAI protocol let by default value (empty)
${SET_PRIMARY_LINK_TIME}  720  # Maximum time in seconds to wait for Primary Link set on ${BTS_PRIMARY_LINK}, default value: 720
${SET_PRIMARY_LINK_PROCEDURE}  LANE  # Procedure for setting BTS_PRIMARY_LINK, possible values: BTS (BTS Reset), LANE (Lock Unlock SFP LANE)
${NR_RESET_WRN_THR}  600  # Compared with the time spent between first cell down and last cell up.
                          # If exceeds NR_RESET_WRN_THR, test verdict will be failed and snapshot collected.
                          # Default value: in accordance with KPI 1a specifications
${NR_MAX_WAIT_TIME}  900  # Maximum time for wait of BTS OnAir (first cell up after reset). If this value is exceeded, test will fail
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
TC__NRL__STATE__NR_Site_Reset_from_WEBEM_fALU_RMs
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-17205
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  NR-LTE test case for NR Reset Site, - x times sequence.
    ...  x - value of REPEAT_COUNTER parameter (default: 3)
    ...  The main steps performed for the test are:
    ...  - check initial state and alarms for both BTS
    ...  - set if needed shared RMOD primary link on requested BTS
    ...  - perform NR Reset Site operation
    ...  - check reset behavior on both BTS based on info from IMS file as follows:
    ...    - NR BTS: reset number is 1
    ...    - LTE BTS: reset number is 0
    ...  - check final state and alarms for both BTS
    ...  Pass criteria: NR Reset Site operation works as expected, states and alarms are as expected
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 22.08.2019 - https://jiradc.ext.net.nokia.com/browse/TAT-17205 - [NR]Create new automated test NRL__STATE_NR_Site_Reset_from WEBEM
    ...  - 14.10.2019 - https://jiradc.ext.net.nokia.com/browse/TAT-17835 - Primary CPRI enhancement
    ...  - 21.10.2019 - https://jiradc.ext.net.nokia.com/browse/TAT-17814 - [NR]Need to increase time for cells check
    ...  - 14.11.2019 - https://jiradc.ext.net.nokia.com/browse/TAT-18116 - CPRI primary set for TDD RM : robot TC enhancement
    ...  - 18.11.2019 - https://jiradc.ext.net.nokia.com/browse/TAT-18273 -
    ...  [NR] Snapshot is not collected when test is passed with restriction due to KPI value not met
    ...  - 12.02.2020 - https://jiradc.ext.net.nokia.com/browse/TAT-18966 - Increase Timeout for Keywords related to Reset behaviour
    ...  - 13.02.2020 - https://jiradc.ext.net.nokia.com/browse/TAT-18907 - Move "Get Current Time " Keywords from Test cases to a common resource
    ...  - 17.02.2020 - https://jiradc.ext.net.nokia.com/browse/TAT-18983 -
    ...  Check if parameter actCategoryAlarms is false/true for NRL__STATE__NR_RM_LockUnlock_from_WEBEM
    ...  - 05.06.2020 - https://jiradc.ext.net.nokia.com/browse/TAT-19638 - Check linkmodesynchronization parameter
    ...  - 07.07.2020 - https://jiradc.ext.net.nokia.com/browse/TAT-19759 -
    ...  Increase time for :KPI1a${NR_RESET_WRN_THR} KPI#3${NR_RESET_WRN_THR} for NRL and NR automated TCs
    ...  - 23.07.2020 - https://jiradc.ext.net.nokia.com/browse/TAT-19956 -
    ...  Refactor tests using "Set RMOD CPRI Primary Status" to provide Master/Slave argument to KW instead of NR/LTE
    ...  - 26.07.2020 - https://jiradc.ext.net.nokia.com/browse/TAT-19840 - Primary link check for CPRI-A RUs LTE/NR reset cases
    ...  - 31.08.2020 - https://jiradc.ext.net.nokia.com/browse/TAT-20103 -
    ...  [NR Obsai] Additional alarms NRL__STATE__NR_Site_Reset_from_WEBEM with DSS configuration
    ...  - 09.09.2020 - https://jiradc.ext.net.nokia.com/browse/TAT-20150 - Additional checks for CPRI status
    ...  - 13.10.2020 - https://jiradc.ext.net.nokia.com/browse/TAT-20237 - Add CPRI primary link check functionality for new TDD RU AWHHF/D
    ...  - 21.10.2020 - https://jiradc.ext.net.nokia.com/browse/TAT-20324 - [Refactoring] Optimize Repeat_Counter loop in test cases - NRL
    ...  - 25.01.2021 - https://jiradc.ext.net.nokia.com/browse/TAT-20783 - [5G] ${fALU_RMOD_TYPE} parameter is not taken into account
    ...  - 25.02.2021 - https://jiradc.ext.net.nokia.com/browse/TAT-20503 - [Cloud] [NRL/SBTS] Cloud behavior Reset Time WRN threshold per Tech
    ...  - 18.03.2021 - https://jiradc.ext.net.nokia.com/browse/TAT-20864 - [Legacy] Pipeline: Clean up robot TC in RFS_SOAM folder - NRL
    ...  - 10.05.2021 - https://jiradc.ext.net.nokia.com/browse/TAT-21302 -
    ...  [Legacy][taf.sbts.oam.coam.admin] Update import in resources, update & test TC LG, MTNRL
    ...  - 03.09.2021 - https://jiradc.ext.net.nokia.com/browse/TAT-21804 - [5G] Refactoring due to stateInfo changes: NRL
    ...  - 13.10.2021 - https://jiradc.ext.net.nokia.com/browse/TAT-21929 -
    ...  [5G] Enhancement for TC NRL__STATE__NR_Site_Reset_from_WEBEM: check eCPRI RMOD behaviour during peer reset
    ...  - 13.12.2021 - https://jiradc.ext.net.nokia.com/browse/TAT-22252 -
    ...  [5G][PrimaryLink] Refactor NRL__STATE__NR_Site_Reset_from_WEBEM to use
    ...  'hran_general.Set Primary Link status based on linkModeSynchronization'
    ...  - 06.01.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-21775 - [5G][Legacy][RFSplit] Test NRL Common Part (hran_ta)
    ...  - 17.01.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-22479 - [5G] [PrimaryLink] [P3] NRL_STATE_ , NRL_SWM_ tests Use
    ...  'Set Primary Link status based on linkModeSynchronization'
    ...  - 31.01.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-22474 -
    ...  [5G] [DSS Refactoring] Implement common procedure for DSS alarms in NRL tests
    ...  - 09.02.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-22580 - [5G][HW file removal] Implement HW file removal in
    ...  NRL_STATE_NR_Site_Reset - w06
    ...  - 14.02.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-22640 - [Cloud] [RFSplit] [Legacy] Particular teardown refactoring - NRL part
    ...  - 28.03.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-22747
    ...  [5G][PrimaryLink] Restore ${fALU_RMOD_TYPE} option for NRL__STATE__NR_Site_Reset_from_WEBEM, NRL__STATE__LTE_Site_Reset_from_WEBEM
    ...  - 28.03.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-22645
    ...  - [5G] test fails instantly on eCPRI configuration where Primary Link set to Master
    ...  - 29.03.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-22801 - [5G] availabilityStatus check when RMOD is OnAir :
    ...  LTE_BBMOD_Reset_from_WEBEM, NR_BBMOD_Reset_from_WEBEM, NR_Site_Reset_from_WEBEM
    ...  - 12.07.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23406 - NRL__STATE__NR_Site_Reset_from_WEBEM failed
    ...  - 12.09.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23368 -
    ...  [Cloud][Pilot robotws][PyLibraries] Drop "hran-tools" library KWs used by RFS TCs
    ...  - 20.09.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23736 - [5G] Rename
    ...  NRL__STATE__NR_Site_Reset_from_WEBEM & NRL__STATE__LTE_Site_Reset_from_WEBEM for formerALU module
    ...  - 02.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23886 - [5G][TC review][NRL] Remove Cells "AdministrativeState" check in all
    ...  NRL robots
    ...  - 12.01.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24426 - [5G]Update scenarios to take reset number from ims2 - NRL, Site_Reset,
    ...  fALU - with TAT-24370
    ...  - 12.01.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24370 - [5G] KPI1a: Update KPI calculation to use: taf.ul.oam_kpi_calculations -
    ...  NRL, Site_Reset, fALU - with TAT-24226
    ...  - 22.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24919 -
    ...  [5G][Refactoring Tracker] Use generic BTS KWs (instead specific RAT KWs) for NRL scenarios
    ...  19.10.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25678 - [5G] Use new DSS mechanism in existing TCs - NRL fALU - w TAT-26251
    ...  19.10.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26251 - [5G][fALU] Checks regarding Primary Link for fALU in tests
    ...  NRL__STATE__NR_Site_Reset_from_WEBEM_fALU_RMs - w TAT-25678
    ...  - 23.10.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26298 - [5G] Add proper description for HWF Feature.
    ...  - 22.12.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26596 -
    ...  [5G][HW file removal] Update HW file removal mechanism in Site Reset fALU tests
    ...  - 15.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26550 - [5G] Update NRL__STATE__NR_Site_Reset_from_WEBEM_fALU_RMs to detect RMOD
    ...  primary link and treat DSS alarms accordingly
    ...  - 12.04.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27210 - [5G][DSS alarms]Add wait_for_alarm_clear because DSS alarms are not
    ...  cleared in current timer - NRL
    ...  - 02.08.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27823 - [CNI-127210] [Part 2] DSS LTE EXPECTED alarms check removal NR_* TCs
    ...  - after DSS discussion is concluded
    ...  - 26.09.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28126 - [5G] CNI : 131510 - Classical - Part 1 - Graceful cell shutdown
    ...  - 16.09.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29822 -
    ...  Unify alarm list names in order alarm list to begin with upper case Alias - NRL
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...  .. image:: https://gitlabe1.ext.net.nokia.com/panda-docs/hran_doc/-/blob/master/testsuite/RFS_SOAM/
    ...  TAT-17205_NRL__STATE__NR_Site_Reset_from_WEBEM.png

    Set Tags    CA-STATE    OWNER-bogdan.vinereanu@nokia.com    AUTHOR-dinu.olariu@nokia.com    PHASE-QT    SW-5G19,SBTS19

    Primary Link TC Parameter Check
    Configure Hardware File
    Step 1: Check initial all BTS state
    Step 2: Check initial all BTS alarms
    Step 3: Get all RMOD info
    FOR  ${INDEX}  IN RANGE  1  ${REPEAT_COUNTER}+1
        Log  ==============================================================================  console=True
        Log  Start Cycle ${INDEX} of ${REPEAT_COUNTER}  console=True
        Log  ==============================================================================  console=True
        Step 4: Set shared RMOD Primary Link before NR Reset Site operation
        Step 5: Reset Site NR and export results for iteration ${INDEX}
        Step 6: Check final all BTS state
        Step 7: Check final all BTS alarms
        Step 8: Check both BTS reset behavior based on IMS info
        Step 9: Get and check KPI1a info from IMS file for iteration ${INDEX}
        Step 10: Check final number and state of Cells and RMs
    END

    [Teardown]  Particular Teardown

Configure Hardware File
    Return From Keyword If  '${SWCONFIG_CHANGE_FLAG}' == 'False'
    Set HWF Flags  swconfig_flag_action=${SWCONFIG_FLAG_ACTION}  swconfig_flag_list=${SWCONFIG_FLAG_LIST}  alias=Master

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

Step ${index}: Set shared RMOD Primary Link before NR Reset Site operation
    [Documentation]
    ...  Set shared RMOD Primary Link if needed

    Log  Step ${index}: Set shared RMOD Primary Link before NR Reset Site operation  console=True
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
    Get LTE cell list from shared RM
    Check RMOD L3 Protocol  Master
    Set Test Variable  ${Master_module_list}  ${Master_shared_RM_list}
    Set Test Variable  ${Slave_module_list}  ${Slave_shared_RM_list}
    Get RMOD ID SN dict  Master
    Get RMOD ID SN dict  Slave

    ${Master_CPRI_RMOD_list}=  Create List
    ${Slave_CPRI_RMOD_list}=  Create List
    ${Master_CPRI_ALU_RMOD_list}=  Create List
    ${Slave_CPRI_ALU_RMOD_list}=  Create List

    FOR  ${item}  IN  @{Master_shared_RM_list}
        ${RMOD_SN}=  Get From Dictionary  ${Master_module_ID_SN_dict}  ${item}
        ${LTE_RMOD_id}=  Get From Dictionary  ${Slave_module_SN_ID_dict}  ${RMOD_SN}
        ${RMOD_L3_Protocol}=  Get From Dictionary  ${Master_RMOD_L3Protocol_dict}  ${item}
        Run Keyword If  '${RMOD_L3_Protocol}' == 'CPRI_RP1'  Run Keywords
        ...  Append To List  ${Master_CPRI_RMOD_list}  ${item}
        ...  AND  Append To List  ${Slave_CPRI_RMOD_list}  ${LTE_RMOD_id}
        ...  ELSE IF  '${RMOD_L3_Protocol}' == 'CPRI_ALU'  Run Keywords
        ...  Append To List  ${Master_CPRI_ALU_RMOD_list}  ${item}
        ...  AND  Append To List  ${Slave_CPRI_ALU_RMOD_list}  ${LTE_RMOD_id}
    END
    Set Test Variable  ${Master_CPRI_RMOD_list}
    Set Test Variable  ${Slave_CPRI_RMOD_list}
    Set Test Variable  ${Master_CPRI_ALU_RMOD_list}
    Set Test Variable  ${Slave_CPRI_ALU_RMOD_list}
    ${CPRI_RMOD_count}=  Get Length  ${Master_CPRI_RMOD_list}
    ${CPRI_ALU_RMOD_count}=  Get Length  ${Slave_CPRI_ALU_RMOD_list}
    Set Test Variable  ${CPRI_RMOD_count}
    Set Test Variable  ${CPRI_ALU_RMOD_count}

Step ${index}: Reset Site NR and export results for iteration ${CYCLE}
    [Documentation]
    ...  Reset Site procedure is launched on NR BTS.

    [Timeout]  20 min
    Log  Step ${index}: Reset Site NR and export results for iteration ${CYCLE}  console=True

    Log  Perform "Reset Site" operation on NR BTS from Admin  console=True
    Get start RESET timestamp info
    RFS Site Reset  connection=Master  graceful_cell_shutdown=${GRACEFUL_CELL_SHUTDOWN}
    Wait For Target To Be Not Reachable TAF  hostname=${MASTER['MASTER_TECH_IP_ADDRESS']}  timeout=300
    Get Current Time  nr_initial
    Log  NR reset_start_time is: ${time_nr_initial}  console=True
    Run Keyword If  '${BTS_PRIMARY_LINK}' in ['Master', 'Slave']  Check peer states and alarms
    Wait For Target To Be Reachable TAF  hostname=${MASTER['MASTER_TECH_IP_ADDRESS']}  timeout=300
    Get Current Time  nr_final
    Log  NR reset_end_time is: ${time_nr_final}  console=True
    ${elapsed_time}=  DateTime.Subtract Date from Date  ${time_nr_final}  ${time_nr_initial}  number
    ${remained_time}=  BuiltIn.Evaluate  ${NR_MAX_WAIT_TIME} - ${elapsed_time}
    ${CELL_state_enabled_check}=  Set Variable  operationalState=${Enabled_}
    Assert Every  NRCEL  ${CELL_state_enabled_check}  timeout=${remained_time}  alias=Master
    Get end RESET timestamp info

Get ${when} RESET timestamp info
    Get Current Date UTC info  ${when}
    Log  UTC ${when}_point_timestamp: ${date_timestamp_${when}_UTC}  console=True

Step ${index}: Check both BTS reset behavior based on IMS info
    [Documentation]
    ...  RESET info is taken from IMS file for both NR and LTE. Reset behavior as expected if:
    ...  - NR site: reset number is 1
    ...  - LTE site: reset number is 0
    ...  Otherwise, reset behavior not as expected, then errors are added to report and failed.

    Log  Step ${index}: Check both BTS reset behavior based on IMS info  console=True
    Get and check BTS RESET info from IMS file  expected_reset_number=1  alias=Master  remove_ims_file=False
    ...  start_point_timestamp_UTC=${date_timestamp_start_UTC}  end_point_timestamp_UTC=${date_timestamp_end_UTC}
    Get and check BTS RESET info from IMS file  expected_reset_number=0  alias=Slave  remove_ims_file=False
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
    ...  kpi_names=kpi1a  kpi_thresholds=${NR_RESET_WRN_THR}  alias=Master  start_point_timestamp_UTC=${date_timestamp_start_UTC}
    ...  end_point_timestamp_UTC=${date_timestamp_end_UTC}
    ${kpi_delta_list}=  Get From Dictionary  ${kpi_name_delta_dict}  kpi1a

    Export KPI Results to File  alias=Master  obj=BTS  obj_type=NR  obj_id=Master  action_1=Site_Reset  kpi_reported_1=KPI_1a
    ...  event_value_1=${kpi_delta_list[0]}  cycle=${CYCLE}  source_info=ims

Check RMOD L3 Protocol
    [Arguments]  ${alias}
    Set Test Variable  ${RMOD_L3Protocol}  None
    ${RMOD_L3Protocol_dict}=  Admin Get RMOD L3 Protocol Info  ${alias}
    Set Test Variable  ${${alias}_RMOD_L3Protocol_dict}  ${RMOD_L3Protocol_dict}

Get NR cell list from shared RM
    ${Master_shared_RM_CELL_list}=  Create List
    FOR  ${item}  IN  @{Master_shared_RM_list}
        ${Master_CELL_RM_list}=  Get Cell Mapping By Module Id  module_id=${item}  alias=Master
        Append To List  ${Master_shared_RM_CELL_list}  @{Master_CELL_RM_list}
    END
    ${Master_shared_RM_CELL_list}=  Remove Duplicates  ${Master_shared_RM_CELL_list}
    [Return]  ${Master_shared_RM_CELL_list}

Get LTE cell list from shared RM
    ${LTE_CELL_RM_list}=  Create List
    FOR  ${item}  IN  @{Slave_shared_RM_list}
        ${LTE_CELL_RM_list_temp}=  Get Cell Mapping By Module Id  module_id=${item}  alias=Slave
        Append To List  ${LTE_CELL_RM_list}  @{LTE_CELL_RM_list_temp}
    END
    ${LTE_CELL_RM_list}=  Remove Duplicates  ${LTE_CELL_RM_list}
    Set Test Variable  ${LTE_CELL_RM_list}
    ${LTE_CELL_RM_count}=  Get Length  ${LTE_CELL_RM_list}
    Set Test Variable  ${LTE_CELL_RM_count}

Check peer states and alarms
    ${SLAVE_EXPECTED_ALARMS_10_1815_full}=  Prepare expected alarms list  ${SLAVE_EXPECTED_ALARMS_10_1815}  ${CPRI_RMOD_count}
    ${SLAVE_EXPECTED_ALARMS_full}=  Run Keyword If  '${BTS_PRIMARY_LINK}' == 'Master'
    ...  Set Variable  ${SLAVE_EXPECTED_ALARMS_10_1815_full}
    ...  ELSE  Create List
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_nr_initial}  ${NR_MAX_WAIT_TIME}
    Run Keyword If  '${BTS_PRIMARY_LINK}' == 'Master'  Run Keywords
    ...  Check Cells State  LNCEL  ${LTE_CELL_RM_list}  operationalState=${Disabled}  ${remained_MAX_WAIT_TIME}  Slave
    ...  AND  Log  LTE cells are disabled  console=True
    ...  ELSE IF  '${BTS_PRIMARY_LINK}' == 'Slave'  Run Keywords
    ...  Check Cells State  LNCEL  ${LTE_CELL_RM_list}  operationalState=${Enabled_}  ${remained_MAX_WAIT_TIME}  Slave
    ...  AND  Log  LTE cells are enabled  console=True

    Run Keyword If  '${BTS_PRIMARY_LINK}' == 'Slave'  Run Keywords
    ...  Assert Every  RMOD  operationalState=${Enabled_}  timeout=5  alias=Slave
    ...  AND  Log  All LTE RMOD - operationalState=Enabled  console=True

    ${SLAVE_IGNORED_ALARMS_full}=  Run Keyword If  '${BTS_PRIMARY_LINK}' == 'Master'
    ...  Combine Lists  ${SLAVE_IGNORED_ALARMS}  ${SLAVE_IGNORED_ALARMS_4764}
    ...  ELSE
    ...  Combine Lists  ${SLAVE_IGNORED_ALARMS_DSS}  ${SLAVE_IGNORED_ALARMS}
    Run Keyword If  ${CPRI_RMOD_count} and '${BTS_PRIMARY_LINK}' == 'Master'
    ...  Log Long String  LTE "Not able to synchronize baseband bus (1815)" or "No connection to unit (10)" alarm,
    ...  expected number: ${CPRI_RMOD_count}  console=True
    Get and Check Alarms SOAM  alias=Slave  expected_alarms=${SLAVE_EXPECTED_ALARMS_full}  ignored_alarms=${SLAVE_IGNORED_ALARMS_full}
    ...  critical_alarms=${SLAVE_CRITICAL_ALARMS}
    Run Keyword If  ${CPRI_RMOD_count} and '${BTS_PRIMARY_LINK}' == 'Master'
    ...  Log Long String  LTE "Not able to synchronize baseband bus (1815)" or "No connection to unit (10)" alarm,
    ...  found number: ${CPRI_RMOD_count}, as expected!  console=True

Check Cells State
    [Arguments]  ${CELL_class}  ${CELL_list}  ${states}  ${timeout}  ${alias}
    FOR  ${item}  IN  @{CELL_list}
        Assert  ${CELL_class}  ${item}  ${states}  timeout=${timeout}  alias=${alias}
    END

Hardware File Teardown
    Return From Keyword If  '${SWCONFIG_CHANGE_FLAG}' == 'False'
    Recover HWF Flags  alias=Master

Particular Teardown
    Export KPI results to File Global  kpi_log_file_name=KpiTimeInfo
    Hardware File Teardown

TC Setup
    ${tech_preset_list}=  Create List  SBTS  SBTS
    Common Test Setup  preset_techs=${tech_preset_list}  common_sbts=${TRUE}  infomodelSetup=${FALSE}

TC Teardown
    Common Test Teardown
