*** Settings ***
Documentation    TC__NR_SBTS__STATE__SBTS_RAT_Reset_from_WEBEM
Variables    ./tc_variables/nr_sbts__state__sbts_rat_reset_from_webem_alarms_definitions.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${REPEAT_COUNTER}                3       # Number of SBTS reset RAT operations, default value 3
${RAT_TECH}                              # Technology for SBTS RAT reset, possible values: empty, LTE, WCDMA or GSM;
                                         # default value: empty (all existing RAT are reset)
${BTS_PRIMARY_LINK}                      # BTS primary link set before SBTS RAT Reset, possible values: empty (no set required),
                                         # Master (Master set required) or Slave (Slave set required); default value: empty
${SET_PRIMARY_LINK_TIME}         720     # Maximum time in seconds to wait for Primary Link set on ${BTS_PRIMARY_LINK}, default value: 720
${SET_PRIMARY_LINK_PROCEDURE}    LANE    # Procedure for setting BTS_PRIMARY_LINK, possible values: BTS (BTS Reset), LANE (Lock Unlock SFP LANE)
${LTE_RESET_WRN_THR}             120     # Time from first cell down to last cell up defined in seconds for LTE RAT.
                                         # Defaults to 120, in accordance with KPI7 specifications
${WCDMA_RESET_WRN_THR}           120     # Time from first cell down to last cell up defined in seconds for WCDMA RAT.
                                         # Defaults to 120, in accordance with KPI8 specifications
${GSM_RESET_WRN_THR}             120     # Time from first cell down to last cell up defined in seconds for GSM RAT.
                                         # Defaults to 120, in accordance with KPI9 specifications
${MAX_WAIT_TIME}                 900     # Maximum time for wait of RAT OnAir
${GRACEFUL_CELL_SHUTDOWN}        True   # Graceful cell shutdown: True or False; default value: True

*** Keywords ***
TC__NR_SBTS__STATE__SBTS_RAT_Reset_from_WEBEM
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-18912
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  NR-SBTS test case for SBTS RAT reset, - x times sequence.
    ...  x - value of REPEAT_COUNTER parameter (default: 3)
    ...  The main steps performed for the test are:
    ...  - set if needed primary CPRI on requested technology
    ...  - check initial state and alarms for both NR and SBTS technologies
    ...  - get initial RESET info from IMS files for NR and SBTS
    ...  - perform Reset RAT operation on SBTS Slave as follows:
    ...    - if ${RAT_TECH} is empty (default value), all existing SBTS RAT are reset one by one
    ...    - if ${RAT_TECH} is set to a specific technology (LTE, WCDMA or GSM), only that SBTS RAT is reset
    ...  - check reset behavior on NR and SBTS based on initial and final RESET info as follows:
    ...    - NR site: reset number is 0
    ...    - SBTS site: reset number is 0
    ...  - check final state and alarms for both NR and SBTS technologies
    ...  Pass criteria: SBTS Reset RAT operation works as expected, states and alarms are as expected
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 05.02.2020 - https://jiradc.ext.net.nokia.com/browse/TAT-18912 -
    ...  [NR][P7] Create new automated test NR_SBTS__STATE__SBTS_RAT_Reset_from_WebEM
    ...  - 12.02.2020 - https://jiradc.ext.net.nokia.com/browse/TAT-18966 - Increase Timeout for Keywords related to Reset behaviour
    ...  - 17.02.2020 - https://jiradc.ext.net.nokia.com/browse/TAT-18983 -
    ...  Check if parameter actCategoryAlarms is false/true for NRL__STATE__NR_RM_LockUnlock_from_WEBEM
    ...  - 13.05.2020 - https://jiradc.ext.net.nokia.com/browse/TAT-19484 -
    ...  Add check of availabilityStatus of LNCELs to be failed or offline in TC NR_SBTS__STATE__SBTS_RAT_Reset_from_WEBEM
    ...  - 23.07.2020 - https://jiradc.ext.net.nokia.com/browse/TAT-19956 -
    ...  Refactor tests using "Set RMOD CPRI Primary Status" to provide Master/Slave argument to KW instead of NR/LTE
    ...  - 30.09.2020 - https://jiradc.ext.net.nokia.com/browse/TAT-20263 -
    ...  NR SBTS DSS] Enhancement should be done for NR SBTS tests for DSS OBSAI/CPRI configurations - part3
    ...  - 13.10.2020 - https://jiradc.ext.net.nokia.com/browse/TAT-20237 - Add CPRI primary link check functionality for new TDD RU AWHHF/D
    ...  - 14.10.2020 - https://jiradc.ext.net.nokia.com/browse/TAT-20319 - [Refactoring] Optimize Repeat_Counter loop in test cases - NR-SBTS
    ...  - 23.03.2021 - https://jiradc.ext.net.nokia.com/browse/TAT-20865 - [Legacy] Pipeline: Clean up robot TC in RFS_SOAM folder - NR_SBTS
    ...  - 12.05.2021 - https://jiradc.ext.net.nokia.com/browse/TAT-21303 - [Legacy][taf.sbts.oam.coam.admin] Udate & test TC NR_SBTS
    ...  - 01.07.2021 - https://jiradc.ext.net.nokia.com/browse/TAT-21124 -
    ...  [5G][SBTS]Automated_RFS_NR_SBTS__STATE__SBTS_RAT_Reset_from_WEBEM_LTE Need to be improved
    ...  - 06.07.2021 - https://jiradc.ext.net.nokia.com/browse/TAT-21512 -
    ...  [5G] Please increase timeout for LTE RAT reset, from 180s to 270s for ABIO/ABIN type
    ...  - 28.07.2021 - https://jiradc.ext.net.nokia.com/browse/TAT-21639 -
    ...  [5G][SBTS]NR_SBTS__STATE__SBTS_RAT_Reset_from_WEBEM_LTE fails with missing alarms
    ...  - 04.08.2021 - https://jiradc.ext.net.nokia.com/browse/TAT-21703 -
    ...  [5G] NR_SBTS__STATE__SBTS_RAT_Reset_from_WEBEM not working for GSM RAT
    ...  - 14.09.2021 - https://jiradc.ext.net.nokia.com/browse/TAT-21804 - [5G] Refactoring due to stateInfo changes: NR_SBTS
    ...  - 13.01.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-22475 -
    ...  [5G] [Refactoring] Use common procedure for DSS alarms in NR_SBTS scenarios (use Get NR LTE DSS info dict)
    ...  - 14.01.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-21776 - [5G][Legacy][RFSplit] Test NRSBTS Common Part (hran_ta)
    ...  - 20.01.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-22362 - [5G][PrimaryLink] [P4] NR_SBTS__STATE__ TCs refactor to use
    ...  'hran_general.Set Primary Link status based on linkModeSynchronization'
    ...  - 16.12.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24215 - [5G][refactoring] Add generalized implementation of "Open new admin
    ...  session" in TCs NR_SBTS - pair with TAT-24247
    ...  - 14.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24197 - [5G][Reset Number ims2] Update NR-SBTS STATE
    ...  scenarios to take reset number from ims2 - P2
    ...  - 19.05.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25387 -
    ...  [5G] New implementation KPI7,8,9,10 measurement +TC verdict from ims2 for NR_SBTS__STATE__SBTS_RAT_Reset_from_WEBEM
    ...  - 22.06.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25594 - [5G] Same KPI value found in KPI file for automated RAT reset scenarios
    ...  - 04.10.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25836 - [5G] Use new DSS mechanism in existing TCs - NR_SBTS RAT actions
    ...  - 24.10.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26296 - [5G] In NR_SBTS__STATE__NR_Cell_BlockUnblock_from_WEBEM info about DSS
    ...  should not be get from ${BTS_DSS_LTE_NR_CELL_runtime_dict}, if DSS isn't configure
    ...  - 26.09.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28126 - [5G] CNI : 131510 - Classical - Part 1 - Graceful cell shutdown
    ...  - 24.10.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26296 - [5G] In NR_SBTS__STATE__NR_Cell_BlockUnblock_from_WEBEM info about DSS
    ...  should not be get from ${BTS_DSS_LTE_NR_CELL_runtime_dict}, if DSS isn't configure
    ...  - 24.10.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29823 -
    ...  Unify alarm list names in order alarm list to begin with upper case Alias - NR_SBTS
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...  .. image:: https://gitlabe1.ext.net.nokia.com/panda-docs/hran_doc/-/blob/master/testsuite/RFS_SOAM/
    ...  TAT-18912_NR_SBTS__STATE__SBTS_RAT_Reset_from_WEBEM.png

    Set Tags    CA-STATE    OWNER-rafael.coman@nokia.com    AUTHOR-dinu.olariu@nokia.com    PHASE-QT    SW-5G19,SBTS19

    Primary Link TC Parameter Check
    Step 1: Check initial all BTS state
    Step 2: Check initial all BTS alarms
    FOR  ${INDEX}  IN RANGE  1  ${REPEAT_COUNTER}+1
        Log  ==============================================================================  console=True
        Log  Start Cycle ${INDEX} of ${REPEAT_COUNTER}  console=True
        Log  ==============================================================================  console=True
        Set Shared RMOD Primary Link before SBTS RAT Reset operation
        Step 3: Reset SBTS RAT on iteration ${INDEX}
        Step 4: Check final all BTS state
        Step 5: Check final all BTS alarms
        Step 6: Check NR and SBTS reset behavior based on IMS info
        Step 7: Check final number and state of Cells and RMs
    END
    [Teardown]  Particular Teardown

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

Step ${index}: Reset SBTS RAT on iteration ${CYCLE}
    [Documentation]
    ...  Reset RAT procedure is launched on SBTS Slave.

    [Timeout]  20 min
    Log  Step ${index}: Reset SBTS RAT  console=True
    ${BTS_XP_localAlias_remoteAlias_dict}  ${NRBTS_DSS_alias_actLteNrDss_dict}  ${LNBTS_DSS_alias_actLteNrDss_dict}  ${BTS_DSS_NR_LTE_CELL_scf_dict}
    ...  ${BTS_DSS_LTE_NR_CELL_scf_dict}  ${BTS_DSS_NR_LTE_CELL_runtime_dict}  ${BTS_DSS_LTE_NR_CELL_runtime_dict}=  Get all BTS DSS feature info
    ${LNBTS_actLteNrDss}=  Get From Dictionary  ${LNBTS_DSS_alias_actLteNrDss_dict}  Slave
    ${DSS_LTE_NR_CELL_dict}=  Run Keyword If  ${LNBTS_actLteNrDss}  Get From Dictionary  ${BTS_DSS_LTE_NR_CELL_runtime_dict}  Slave
    ...  ELSE  Create Dictionary
    Set Test Variable  ${DSS_LTE_NR_CELL_dict}
    Set Test Variable  ${LNBTS_actLteNrDss}

    Run Keyword If  '${RAT_TECH}' in ['LTE',''] and ${SBTS_LTE_cell_ids}  Run Keywords
    ...  Set Test Variable  ${RESET_WRN_THR}  ${LTE_RESET_WRN_THR}
    ...  AND  Reset SBTS RAT  LTE  ${CYCLE}
    Run Keyword If  '${RAT_TECH}' in ['WCDMA',''] and ${SBTS_WCDMA_cell_ids}  Run Keywords
    ...  Set Test Variable  ${RESET_WRN_THR}  ${WCDMA_RESET_WRN_THR}
    ...  AND  Reset SBTS RAT  WCDMA  ${CYCLE}
    Run Keyword If  '${RAT_TECH}' in ['GSM',''] and ${SBTS_GSM_cell_ids}  Run Keywords
    ...  Set Test Variable  ${RESET_WRN_THR}  ${GSM_RESET_WRN_THR}
    ...  AND  Reset SBTS RAT  GSM  ${CYCLE}

Step ${index}: Check NR and SBTS reset behavior based on IMS info
    [Documentation]
    ...  Final RESET info are compared with initial RESET info for both NR and SBTS based on IMS. Reset behavior as expected if:
    ...  - NR site: reset number is 0
    ...  - SBTS site: reset number is 0
    ...  Otherwise, reset behavior not as expected, then errors are added to report and failed.

    Log  Step ${index}: Check NR and SBTS reset behavior based on IMS info  console=True
    Get and check BTS RESET info from IMS file  expected_reset_number=0  alias=Master  remove_ims_file=False
    ...  start_point_timestamp_UTC=${date_timestamp_start_resetRAT_UTC}  end_point_timestamp_UTC=${date_timestamp_end_resetRAT_UTC}
    Get and check BTS RESET info from IMS file  expected_reset_number=0  alias=Slave  remove_ims_file=False
    ...  start_point_timestamp_UTC=${date_timestamp_start_resetRAT_UTC}  end_point_timestamp_UTC=${date_timestamp_end_resetRAT_UTC}

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]
    ...  Following checks are performed:
    ...  - number of configured cells and radio modules in SCF are properly mapped on BTS running view ADMIN
    ...  - check cells states
    ...  - check radio modules states

    Log  Step ${index}: Check final number and state of Cells and RMs  console=True
    RFS Test Case Final Checks

Set Shared RMOD Primary Link before SBTS RAT Reset operation
    [Documentation]
    ...  Set shared RMOD Primary Link if needed

    Run Keyword If  '${BTS_PRIMARY_LINK}' == ''  Run Keywords
    ...  Highlight Log  Test action will be performed with existing Primary Link configuration
    ...  AND  Return From Keyword
    ...  ELSE IF  '${BTS_PRIMARY_LINK}' in ['Master','Slave']  Run Keywords
    ...  Highlight Log  Test action will be performed with Primary Link set on BTS ${BTS_PRIMARY_LINK}
    ...  AND  Set Primary Link status based on linkModeSynchronization  module_type=RMOD
    ...  procedure_for_Primary_Link_set=${SET_PRIMARY_LINK_PROCEDURE}  alias=${BTS_PRIMARY_LINK}  wait_for_Primary_Link_set=${SET_PRIMARY_LINK_TIME}

Reset SBTS RAT
    [Arguments]  ${techno}  ${CYCLE}
    Run Keyword If  ${LNBTS_actLteNrDss} and '${techno}' == 'LTE'  Get NR DSS alarms
    ${RAT_kpi_name}=  Set Variable If  '${techno}'=='NR'  kpi10  '${techno}'=='LTE'  kpi7  '${techno}'=='WCDMA'  kpi8  '${techno}'=='GSM'  kpi9

    Start new ADMIN instance  alias=Slave  new_alias=resetRAT  enb_ip=192.168.255.1  connection_type=${connection_type_Slave}
    Get Current Date UTC info  start_resetRAT
    Get Current Time  initial

    Log  Perform "Reset ${techno}" operation on SBTS Slave from Admin  console=True
    ${reset_info_thread}=  Run Keyword In Background  Reset Rat  rat_type=${techno}  timeout=${MAX_WAIT_TIME}  connection=resetRAT
    ...  graceful_cell_shutdown=${GRACEFUL_CELL_SHUTDOWN}

    Log  Check ${techno} cell(s) states during Reset ${techno} RAT  console=True
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_initial}  ${MAX_WAIT_TIME}
    Assert Any  class_name=${techno[0]}NCEL  parameters=operationalState=${Disabled_}, availabilityStatus=${Failed_Offline_}
    ...  timeout=${remained_MAX_WAIT_TIME}  connection=Slave
    Get Current Time  first_cell_down
    Log  First ${techno[0]}NCEL down time: ${time_first_cell_down}  console=True

    Start new ADMIN instance  alias=Slave  new_alias=assertCells  enb_ip=192.168.255.1  connection_type=${connection_type_Slave}

    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_initial}  ${MAX_WAIT_TIME}
    ${cell_info_thread}=  Run Keyword In Background
    ...  Assert Every  class_name=${techno[0]}NCEL  parameters=operationalState=${Disabled_}, availabilityStatus=${Failed_Offline_}
    ...  timeout=${remained_MAX_WAIT_TIME}  connection=assertCells
    Log  ${techno} cell(s) states: operationalState=Disabled, availabilityStatus=Failed|Offline  console=True

    Run Keyword If  ${LNBTS_actLteNrDss} and '${techno}' == 'LTE'  Run Keywords
    ...  Get Current Time  dss_check_start
    ...  AND  Log Long String  NR "EN DSS De-activated on partner side (7513)" or "EN DSS Keep Alive Procedure Time out (7511)" alarm,
    ...  expected number: ${NR_alarm_count}  console=True
    ...  AND  Get and Check Alarms SOAM  alias=Master  poll_interval=5 sec  expected_alarms=${MASTER_EXPECTED_ALARMS_DSS_full}
    ...  ignored_alarms=${MASTER_IGNORED_ALARMS}  critical_alarms=${MASTER_CRITICAL_ALARMS}
    ...  AND  Log Long String  NR "EN DSS De-activated on partner side (7513)" alarm or "EN DSS Keep Alive Procedure Time out (7511)",
    ...  found number: ${NR_alarm_count}, as expected!  console=True
    ...  AND  Log  NR site - expected, ignored and critical alarms checked  console=True
    ...  AND  Get Current Time  dss_check_stop

    ${cell_info_result}=  Collect Keyword Result  ${cell_info_thread}  timeout=${MAX_WAIT_TIME}
    ${reset_info_result}=  Collect Keyword Result  ${reset_info_thread}  timeout=${MAX_WAIT_TIME}
    Close ADMIN Session  alias=assertCells

    Log  Check ${techno} cell(s) states after Reset ${techno} RAT  console=True
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_initial}  ${MAX_WAIT_TIME}
    Assert Every  class_name=${techno[0]}NCEL  parameters=operationalState=${Enabled_}  timeout=${remained_MAX_WAIT_TIME}  connection=Slave
    Log  ${techno} cell(s) states: operationalState=Enabled  console=True

    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_initial}  ${MAX_WAIT_TIME}
    Check cells availability status online  Slave  ${remained_MAX_WAIT_TIME}

    Get Current Date UTC info  end_resetRAT

    ${kpi_name_delta_dict}=  Get and check KPI info from IMS file  kpi_names=${RAT_kpi_name}  kpi_thresholds=${${techno}_RESET_WRN_THR}  alias=Slave
    ...  start_point_timestamp_UTC=${date_timestamp_start_resetRAT_UTC}  end_point_timestamp_UTC=${date_timestamp_end_resetRAT_UTC}
    ${kpi_delta_list}=  Get From Dictionary  ${kpi_name_delta_dict}  ${RAT_kpi_name}

    Export KPI Results to File  alias=Slave  obj_info=RAT  obj=BTS KPI measurement
    ...  obj_type=${techno}  obj_id=Slave
    ...  action_1=RAT_Reset  kpi_reported_1=${RAT_kpi_name}  event_value_1=${kpi_delta_list[0]}
    ...  cycle=${CYCLE}  source_info=ims
    ...  add_info_label=RAT_Reset action  add_info_value=Slave

    Log  "Reset ${techno}" operation successfully finished  console=True

    [Teardown]  Close ADMIN Session  alias=resetRAT

Get NR DSS alarms
    ${LTE_NR_CELL_DSS_count}=  Get Length  ${DSS_LTE_NR_CELL_dict}
    Set Test Variable  ${NR_alarm_count}  ${LTE_NR_CELL_DSS_count}
    ${MASTER_EXPECTED_ALARMS_DSS_full}=  Prepare expected alarms list  ${MASTER_EXPECTED_ALARMS_DSS}  ${NR_alarm_count}
    Set Test Variable  ${MASTER_EXPECTED_ALARMS_DSS_full}

Close ADMIN Session
    [Arguments]  ${alias}
    Teardown Admin  alias=${alias}
    Log  SBTS alias ${alias}: Teardown Admin successfully performed  level=TRACE  console=True

Particular Teardown
    Export KPI results to File Global  kpi_log_file_name=KpiTimeInfo

TC Setup
    ${tech_preset_list}=  Create List  SBTS  SBTS
    Common Test Setup  preset_techs=${tech_preset_list}  common_sbts=${TRUE}  infomodelSetup=${FALSE}

TC Teardown
    Common Test Teardown

