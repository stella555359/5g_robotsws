*** Settings ***
Documentation    TC__NRL__STATE__LTE_SM_Power_Off_On_CBRS
Variables    tc_variables/nrl__state__lte_sm_power_off_on_cbrs_alarms_definitions.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${BTS_PRIMARY_LINK}                      # BTS primary link set before LTE SMs Power Off On, possible values: empty (no set required),
                                         # Master (Master set required) or Slave (Slave set required), default value: empty
${SET_PRIMARY_LINK_TIME}       720       # Maximum time in seconds to wait for Primary Link set on ${BTS_PRIMARY_LINK}, default value: 720
${SET_PRIMARY_LINK_PROCEDURE}  LANE      # Procedure for setting BTS PRIMARY LINK, possible values: BTS (BTS Reset), LANE (Lock Unlock SFP LANE)
${REPEAT_COUNTER}              3         # Number of LTE SMs Power Off/On operations, default value 3
${LTE_RESET_WRN_THR}           600       # If LTE reset exceeds LTE_RESET_WRN_THR, test verdict will be failed and snapshot
                                         # collected. Default value: in accordance with KPI 3 specifications
${LTE_MAX_WAIT_TIME}           900       # Maximum time for wait of LTE BTS to be OnAir (all cells up after reset).
                                         # If this value is exceeded, test will fail.

*** Keywords ***
TC__NRL__STATE__LTE_SM_Power_Off_On_CBRS
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-25724
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  NR-LTE test case for LTE SMs Power Off/On, - x times sequence.
    ...  x - value of REPEAT_COUNTER parameter (default: 3)
    ...  The main steps performed for the test are:
    ...  - set if needed primary link on requested technology
    ...  - check initial state and alarms for both NR and LTE technologies
    ...  - perform Power Off/On operation on LTE SMs
    ...  - check reset behavior on NR and LTE based on IMS info as follows:
    ...    - NR site: reset number is 0
    ...    - LTE site: reset number is 1
    ...  - get and check KPI3 info from IMS file
    ...  - check final state and alarms for both NR and LTE technologies
    ...  Pass criteria: LTE SMs Power Off/On operation works as expected, states and alarms are as expected
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 06.09.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25920 -
    ...  [5G][CB008278] NRL__STATE__LTE_SM_Power_Off_On test cases update for CBRS configuration
    ...  - 16.09.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29822 -
    ...  Unify alarm list names in order alarm list to begin with upper case Alias - NRL
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...  .. image:: https://gitlabe1.ext.net.nokia.com/panda-docs/hran_doc/-/blob/master/testsuite/RFS_SOAM/
    ...  TAT-25920_NRL__STATE__LTE_SM_Power_Off_On_CBRS.png

    Set Tags    CA-STATE    OWNER-adrian.chisim@nokia.com    AUTHOR-traian-alin.bacos@nokia.com    PHASE-QT    SW-SBTS24R1

    Primary Link TC Parameter Check
    Step 1: Check initial all BTS state
    Step 2: Check initial all BTS alarms
    Step 3: Check if CBRS is configured
    Step 4: Check PDU definition and reachability
    Step 5: Get all RMOD info
    FOR  ${INDEX}  IN RANGE  1  ${REPEAT_COUNTER}+1
        Log  ==============================================================================  console=True
        Log  Start Cycle ${INDEX} of ${REPEAT_COUNTER}  console=True
        Log  ==============================================================================  console=True
        Step 6: Set shared RMOD Primary Link before LTE SMs Power Off On operation
        Step 7: Power OFF/ON LTE SMs and export results for iteration ${INDEX}
        Step 8: Check final all BTS state
        Step 9: Check final all BTS alarms
        Step 10: Check NR and LTE reset behavior based on IMS info
        Step 11: Get and check KPI3 info from IMS file for iteration ${INDEX}
        Step 12: Check final number and state of Cells and RMs
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

Step ${index}: Check if CBRS is configured
    [Documentation]
    ...  This keyword checks if CBRS feature is enabled on TL or not

    Log  Step ${index}: Check if CBRS is configured  console=True
    ${BTS_scf}=  rfs_admin.Admin Collect scf.xml with timestamp TAF  alias=Master  export_type=configurationAndRuntimeObjects
    ${NR_cell_ids}=  Get Ids For All  NRCEL  connection=Master

    FOR  ${item}  IN  @{NR_cell_ids}
        ${NR_CELL_dn}=  Get CELL SCF runtime distinguished name  ${item}  Master
        ${freqBandIndicatorNR_value}=  Check Parameter value from SCF  item_dist_name=${NR_CELL_dn}  parameter_to_check=freqBandIndicatorNR
        ...  scf_path=${BTS_scf}
        Run Keyword If  '${freqBandIndicatorNR_value}' != '48'  Run Keywords
        ...  Log  Value of freqBandIndicatorNR for ${item} is not as expected (${freqBandIndicatorNR_value} vs. 48). CBRS is not properly configured
        ...  console=True
        ...  AND  Fail  CBRS is not properly configured
    END

Step ${index}: Check PDU definition and reachability
    [Documentation]
    ...  Keyword used to check if BTS SMs PDU are defined, can be reached and their status is on

    Log  Step ${index}: Check PDU definition and reachability  console=True
    ${Slave_SM_PDU_if_name_list}=  Check BTS SMs PDU info definition  Slave
    Set Test Variable  ${Slave_SM_PDU_if_name_list}
    ${status}=  Check BTS SMs PDU port status  ${Slave_SM_PDU_if_name_list}  on
    Run Keyword If  ${status}
    ...  Log  BTS Slave SMs PDU port status as expected  console=True
    ...  ELSE  Run Keywords
    ...  Log  PDU for BTS Slave SMs is either not reachable or not switched on!  level=ERROR
    ...  AND  Fail  PDU for BTS Slave SMs is either not reachable or not switched on!

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
    Check RMOD L3 Protocol  Master

Step ${index}: Power OFF/ON LTE SMs and export results for iteration ${CYCLE}
    [Documentation]
    ...  Keyword is used to change the power state of the LTE SMs and export results.

    Log  Step ${index}: Power OFF/ON LTE SMs and export results for iteration ${CYCLE}  console=True
    ${CELL_state_enabled_check}=  Set Variable  operationalState=${Enabled_}, blockingState=${Unblocked_}
    Get RMOD L3 Protocol  Master
    Check for Mixed RMOD configuration
    Count NR alarms
    ${MASTER_EXPECTED_ALARMS_FULL}=  Create List  @{EMPTY}

    ${MASTER_IGNORED_ALARMS_full}=  Combine Lists  ${MASTER_IGNORED_ALARMS_DURING_LTE_POWERED_OFF}  ${MASTER_IGNORED_ALARMS}

    Log  Perform power off LTE SMs  console=True
    Get start RESET timestamp info
    ${status}=  Set BTS SMs PDU port status  ${Slave_SM_PDU_if_name_list}  off
    Run Keyword If  ${status}
    ...  Log  BTS Slave SMs PDU port status off, as expected  console=True
    ...  ELSE  Run Keywords
    ...  Log  Set BTS Slave SMs PDU port status off failed!  level=ERROR
    ...  AND  Fail  Set BTS Slave SMs PDU port status off failed!

    Log  Waiting 5 minutes after power off LTE SMs  console=True
    Get Current Time  initial
    Log  Check NR state and alarms during interval of 5 minutes:  console=True

    Run Keyword If  '${RMOD_L3Protocol}' in ['RP301_RP1', 'CPRI_RP1', 'Mixed']
    ...  Log  NR "No connection to unit (10)" alarm, expected number: ${alarm_10_count}  console=True
    Get and Check Alarms SOAM  alias=Master  expected_alarms=${MASTER_EXPECTED_ALARMS_RMOD_FULL}  ignored_alarms=${MASTER_IGNORED_ALARMS_full}
    ...  critical_alarms=${MASTER_CRITICAL_ALARMS}  time=10 min
    Run Keyword If  '${RMOD_L3Protocol}' in ['RP301_RP1', 'CPRI_RP1', 'Mixed']
    ...  Log  NR "No connection to unit (10)" alarm, found number: ${alarm_10_count}  console=True

    ${bts_id}=  Get Id For Current  BTS  alias=Master
    Get Current Time  final
    ${powered_off_time}=  DateTime.Subtract Date from Date  ${time_final}  ${time_initial}  number
    ${nr_remained_time}=  BuiltIn.Evaluate  300-${powered_off_time}
    Run Keyword If  ${nr_remained_time} > 0  Sleep  ${nr_remained_time} sec

    Log  Check NR state and alarms after interval of 5 minutes:  console=True

    Get and Check Alarms SOAM  alias=Master  expected_alarms=@{EMPTY}  ignored_alarms=${MASTER_IGNORED_ALARMS_full}
    ...  critical_alarms=${MASTER_CRITICAL_ALARMS}  time=10 min

    Run Keyword If  '${BTS_PRIMARY_LINK}' == 'Slave'  Run Keywords
    ...  Assert  BTS  ${bts_id}  proceduralState=${IntegratedToRan_Configured_}  alias=Master
    ...  AND  Log  NR site - proceduralState=IntegratedToRan|Configured  console=True
    ...  AND  Assert Every  NRCEL  operationalState=${Disabled_}  alias=Master
    ...  AND  Log  NR cells - operationalState=Disabled  console=True

    Log  Perform power on LTE SMs  console=True
    Get Current Date UTC info  power_on
    Set BTS SMs PDU port status  ${Slave_SM_PDU_if_name_list}  on
    ${status}=  Set BTS SMs PDU port status  ${Slave_SM_PDU_if_name_list}  on
    Run Keyword If  ${status}
    ...  Log  BTS Slave SMs PDU port status on, as expected  console=True
    ...  ELSE  Run Keywords
    ...  Log  Set BTS Slave SMs PDU port status on failed!  level=ERROR
    ...  AND  Fail  Set BTS Slave SMs PDU port status on failed!
    Get Current Time  lte_initial
    Log  Power on LTE SMs start time is: ${time_lte_initial}  console=True
    Wait For Target To Be Reachable TAF  hostname=${SLAVE['SLAVE_TECH_IP_ADDRESS']}  timeout=180  remote_host=${SLAVE['SLAVE_PC_IP_ADDRESS']}
    Sleep  120 sec

    Log  Check LTE BTS alarms  console=True
    Get and Check Alarms SOAM  alias=Slave  expected_alarms=@{EMPTY}  ignored_alarms=${SLAVE_IGNORED_ALARMS}  critical_alarms=${SLAVE_CRITICAL_ALARMS}

    Get intermediate RESET timestamp info
    ${elapsed_time}=  DateTime.Subtract Date from Date  ${date_timestamp_intermediate_UTC}  ${date_timestamp_power_on_UTC}  number
    ${remained_time}=  BuiltIn.Evaluate  ${LTE_MAX_WAIT_TIME} - ${elapsed_time}
    Admin Check all BTS cells expected states  ${CELL_state_enabled_check}  Slave  ${remained_time}
    ${remained_time}=  BuiltIn.Evaluate  ${LTE_MAX_WAIT_TIME} - ${elapsed_time}
    Check cells availability status online  Slave  ${remained_time}
    Sleep  30s  Timeout for SM to be able to synchronise after power off
    Get Current Date UTC info  cells_onair
    Get end RESET timestamp info

Step ${index}: Check NR and LTE reset behavior based on IMS info
    [Documentation]
    ...  BTS RESET info is checked based on IMS info. for both NR and LTE. Reset behavior as expected if:
    ...  - NR site: reset number is 0
    ...  - LTE site: reset number is 1
    ...  Otherwise, reset behavior not as expected, then errors are added to report and failed.

    Log  Step ${index}: Check NR and LTE reset behavior based on IMS info  console=True

    Get and check BTS RESET info from IMS file  expected_reset_number=0  alias=Master
    ...  start_point_timestamp_UTC=${date_timestamp_start_UTC}  end_point_timestamp_UTC=${date_timestamp_end_UTC}
    Get and check BTS RESET info from IMS file  expected_reset_number=1  alias=Slave
    ...  start_point_timestamp_UTC=${date_timestamp_start_UTC}  end_point_timestamp_UTC=${date_timestamp_end_UTC}

Step ${index}: Get and check KPI3 info from IMS file for iteration ${CYCLE}
    [Documentation]
    ...  Get and check KPI3 info from IMS file.

    Log  Step ${index}: Get and check KPI3 info from IMS file for iteration ${CYCLE}  console=True

    ${kpi_name_delta_dict}=  Get and check KPI info from IMS file
    ...  kpi_names=kpi3  kpi_thresholds=${LTE_RESET_WRN_THR}  alias=Slave  remove_ims_file=False
    ...  start_point_timestamp_UTC=${date_timestamp_power_on_UTC}  end_point_timestamp_UTC=${date_timestamp_cells_onair_UTC}
    ${kpi_delta_list}=  Get From Dictionary  ${kpi_name_delta_dict}  kpi3
    Export KPI Results to File  alias=Slave  obj=BTS  obj_type=LTE  obj_id=Slave  action_1=BTS_Power_On  kpi_reported_1=KPI_3
    ...  event_value_1=${kpi_delta_list[0]}  cycle=${CYCLE}  source_info=ims

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]
    ...  Following checks are performed:
    ...  - number of configured cells and radio modules in SCF are properly mapped on BTS running view ADMIN
    ...  - check cells states
    ...  - check radio modules states

    Log  Step ${index}: Check final number and state of Cells and RMs  console=True
    RFS Test Case Final Checks

Step ${index}: Set shared RMOD Primary Link before LTE SMs Power Off On operation
    [Documentation]
    ...  Set shared RMOD Primary Link if needed

    Log  Step ${index}: Set shared RMOD Primary Link before LTE SMs Power Off On operation  console=True
    Run Keyword If  '${BTS_PRIMARY_LINK}' == ''  Run Keywords
    ...  Log  ==================================================================================  console=True
    ...  AND  Log  ***** Test action will be performed with existing Primary Link configuration *****  console=True
    ...  AND  Log  ==================================================================================  console=True
    ...  AND  Return From Keyword
    ...  ELSE IF  '${BTS_PRIMARY_LINK}' in ['Master','Slave']  Run Keywords
    ...  Log  =============================================================================  console=True
    ...  AND  Log  ***** Test action will be performed with Primary Link set on BTS ${BTS_PRIMARY_LINK} *****  console=True
    ...  AND  Log  =============================================================================  console=True
    ...  AND  Set Primary Link status based on linkModeSynchronization  module_type=RMOD
    ...  procedure_for_Primary_Link_set=${SET_PRIMARY_LINK_PROCEDURE}
    ...  alias=${BTS_PRIMARY_LINK}  wait_for_Primary_Link_set=${SET_PRIMARY_LINK_TIME}

Get ${when} RESET timestamp info
    Get Current Date UTC info  ${when}
    Log  UTC ${when}_point_timestamp: ${date_timestamp_${when}_UTC}  console=True

Get RMOD L3 Protocol
    [Arguments]  ${alias}
    Set Test Variable  ${RMOD_L3Protocol}  None
    ${RMOD_L3Protocol_dict}=  Admin Get RMOD L3 Protocol Info  ${alias}
    ${RMOD_L3Protocol_values}=  Get Dictionary Values  ${RMOD_L3Protocol_dict}
    ${RMOD_L3Protocol_value}=  Remove Duplicates  ${RMOD_L3Protocol_values}
    ${RMOD_L3Protocol}=  Set Variable If  len(${RMOD_L3Protocol_value}) == 1  ${RMOD_L3Protocol_value[0]}  2  Mixed
    Set Test Variable  ${RMOD_L3Protocol}

Count NR CELL alarms
    [Arguments]  ${RMOD_remapped_list}  ${RMOD_not_remapped_list}
    ${CELL_remapped_list}=  Create list  @{EMPTY}
    ${CELL_not_remapped_list}=  Create list  @{EMPTY}
    FOR  ${item}  IN  @{RMOD_remapped_list}
        ${CELL_RM_list}=  Get Cell Mapping By Module Id  module_id=${item}  alias=Master
        Append To List  ${CELL_remapped_list}  @{CELL_RM_list}
    END
    ${CELL_remapped_list}=  Remove Duplicates  ${CELL_remapped_list}
    ${CELL_remapped_count}=  Get Length  ${CELL_remapped_list}
    Set Test Variable  ${NR_alarm_count}  ${CELL_remapped_count}
    FOR  ${item}  IN  @{RMOD_not_remapped_list}
        ${CELL_RM_list}=  Get Cell Mapping By Module Id  module_id=${item}  alias=Master
        Append To List  ${CELL_not_remapped_list}  @{CELL_RM_list}
    END
    ${CELL_not_remapped_list}=  Remove Duplicates  ${CELL_not_remapped_list}
    ${CELL_not_remapped_count}=  Get Length  ${CELL_not_remapped_list}
    [Return]  ${CELL_remapped_count}  ${CELL_not_remapped_count}

Check for Mixed RMOD configuration
    ${Master_shared_RMOD_list}  ${Slave_shared_RMOD_list}  ${Master_dedicated_RMOD_list}  ${Slave_dedicated_RMOD_list}=
    ...  Admin Get Shared And Dedicated RM List for Master and Slave  Master  Slave
    ${Master_RMOD_L3Protocol_dict}=  Admin Get RMOD L3 Protocol Info  Master
    ${Master_shared_RMOD_CPRI_list}=  Create List
    ${Slave_shared_RMOD_CPRI_list}=  Create List
    FOR  ${Master_RMOD_id}  ${Slave_RMOD_id}  IN ZIP  ${Master_shared_RMOD_list}  ${Slave_shared_RMOD_list}
        ${Master_RMOD_L3Protocol}=  Get From Dictionary  ${Master_RMOD_L3Protocol_dict}  ${Master_RMOD_id}
        Continue For Loop If  '${Master_RMOD_L3Protocol}' != 'CPRI_RP1'
        Append To List  ${Master_shared_RMOD_CPRI_list}  ${Master_RMOD_id}
        Append To List  ${Slave_shared_RMOD_CPRI_list}  ${Slave_RMOD_id}
    END
    ${Master_shared_RMOD_CPRI_count}=  Get Length  ${Master_shared_RMOD_CPRI_list}
    Set Test Variable  ${Master_shared_RMOD_CPRI_count}

Count NR alarms
    Run Keyword If  '${RMOD_L3Protocol}' == 'ECPRI_MPLANE'  Run Keywords
    ...  Count NR alarms for eCPRI
    ...  AND  Return From Keyword
    Run Keyword If  '${RMOD_L3Protocol}' in ['RP301_RP1', 'CPRI_RP1', 'Mixed']  Run Keywords
    ...  Count NR alarms for mixed configuration
    ...  AND  Return From Keyword
    ${RMOD_remapped_list}=  Create list  @{EMPTY}
    ${RMOD_not_remapped_list}=  Create list  @{EMPTY}
    ${Master_Primary_Link_dict}  ${Slave_Primary_Link_dict}=  Get Primary Link status based on linkModeSynchronization  RMOD
    FOR  ${key}  IN  @{Master_Primary_Link_dict.keys()}
        ${value}=  Get From Dictionary  ${Master_Primary_Link_dict}  ${key}
        Run Keyword If  '${value}'=='[True]'  Append To List  ${RMOD_not_remapped_list}  ${key}
        ...  ELSE  Append To List  ${RMOD_remapped_list}  ${key}
    END
    ${RMOD_remapped_count}=  Get Length  ${RMOD_remapped_list}
    ${RMOD_not_remapped_count}=  Get Length  ${RMOD_not_remapped_list}
    ${CELL_remapped_count}  ${CELL_not_remapped_count}=  Count NR CELL alarms  ${RMOD_remapped_list}  ${RMOD_not_remapped_list}
    Set Test Variable  ${RMOD_remapped_count}
    Set Test Variable  ${CELL_not_remapped_count}
    ${MASTER_EXPECTED_ALARMS_RMOD_FULL}=  Prepare expected alarms list  ${MASTER_EXPECTED_ALARMS_10_1815}  ${RMOD_remapped_count}
    Run Keyword If  '${NR_BTS_syncHubRole}' == 'Master'
    ...  Append To List  ${MASTER_EXPECTED_ALARMS_RMOD_FULL}  @{MASTER_EXPECTED_ALARMS_61029}
    Set Test Variable  ${MASTER_EXPECTED_ALARMS_RMOD_FULL}
    ${MASTER_EXPECTED_ALARMS_RMOD_DSS_FULL}=  Create List  @{EMPTY}
    Append To List  ${MASTER_EXPECTED_ALARMS_RMOD_DSS_FULL}  @{MASTER_EXPECTED_ALARMS_RMOD_FULL}
    Set Test Variable  ${MASTER_EXPECTED_ALARMS_RMOD_DSS_FULL}

Count NR alarms for mixed configuration
    ${Master_shared_RM_list}  ${Slave_shared_RM_list}  ${Master_dedicated_RM_list}  ${Slave_dedicated_RM_list}=
    ...  Admin Get Shared And Dedicated RM List for Master and Slave  Master  Slave

    ${all_BTS_PL_shared_RM_info}=  Get PL shared RM info on all BTS
    FOR  ${alias}  IN  @{alias_list}
        ${BTS_PL_shared_RM_info}=  Get From Dictionary  ${all_BTS_PL_shared_RM_info}  ${alias}

        ${BTS_PL_CPRI_shared_RMOD_list}=  Get From Dictionary  ${BTS_PL_shared_RM_info}  BTS_PL_CPRI_shared_RM_id_list
        ${BTS_non_PL_CPRI_shared_RMOD_list}=  Get From Dictionary  ${BTS_PL_shared_RM_info}  BTS_non_PL_CPRI_shared_RM_id_list

        ${BTS_PL_CPRI_shared_RMOD_count}=  Get Length  ${BTS_PL_CPRI_shared_RMOD_list}
        ${BTS_non_PL_ECPRI_shared_RMOD_count}=  Get Length  ${BTS_non_PL_CPRI_shared_RMOD_list}

        Set Test Variable  ${${alias}_PL_CPRI_shared_RMOD_count}  ${BTS_PL_CPRI_shared_RMOD_count}
        Set Test Variable  ${${alias}_non_PL_CPRI_shared_RMOD_count}  ${BTS_non_PL_ECPRI_shared_RMOD_count}
    END

    ${Master_shared_RM_CELL_list}=  Create List
    FOR  ${item}  IN  @{Master_shared_RM_list}
        ${Master_CELL_RM_list}=  Get Cell Mapping By Module Id  module_id=${item}  alias=Master
        Append To List  ${Master_shared_RM_CELL_list}  @{Master_CELL_RM_list}
    END
    ${Master_shared_RM_CELL_list}=  Remove Duplicates  ${Master_shared_RM_CELL_list}
    ${RMOD_remapped_count}=  Get Length  ${Master_shared_RM_list}
    Set Test Variable  ${RMOD_remapped_count}
    ${alarm_10_count}=  Evaluate  ${RMOD_remapped_count} - ${Master_PL_CPRI_shared_RMOD_count}
    ${MASTER_EXPECTED_ALARMS_RMOD_FULL}=  Prepare expected alarms list  ${MASTER_EXPECTED_ALARMS_10_1815}  ${alarm_10_count}
    Set Test Variable  ${alarm_10_count}
    Set Test Variable  ${MASTER_EXPECTED_ALARMS_RMOD_FULL}
    ${MASTER_EXPECTED_ALARMS_DSS_FULL}=  Create List  @{EMPTY}
    Set Test Variable  ${MASTER_EXPECTED_ALARMS_DSS_FULL}
    ${MASTER_EXPECTED_ALARMS_RMOD_DSS_FULL}=  Create List  @{EMPTY}
    Append To List  ${MASTER_EXPECTED_ALARMS_RMOD_DSS_FULL}  @{MASTER_EXPECTED_ALARMS_RMOD_FULL}
    Append To List  ${MASTER_EXPECTED_ALARMS_RMOD_DSS_FULL}  @{MASTER_EXPECTED_ALARMS_DSS_FULL}
    Set Test Variable  ${MASTER_EXPECTED_ALARMS_RMOD_DSS_FULL}

Count NR alarms for eCPRI
    ${MASTER_EXPECTED_ALARMS_16_full}=  Prepare expected alarms list  ${MASTER_EXPECTED_ALARMS_16}  ${shared_RM_count}
    ${MASTER_EXPECTED_ALARMS_RMOD_FULL}=  Create List  @{EMPTY}
    Set Test Variable  ${MASTER_EXPECTED_ALARMS_RMOD_FULL}
    Run Keyword If  '${BTS_PRIMARY_LINK}' == 'Slave'  Run Keywords
    ...  Log  NR "Unit synchronization failed (16)" alarm, expected number: ${shared_RM_count}  console=True
    ...  AND  Append To List  ${MASTER_EXPECTED_ALARMS_RMOD_FULL}  @{MASTER_EXPECTED_ALARMS_16_full}
    ${Master_shared_RM_list}  ${Slave_shared_RM_list}  ${Master_dedicated_RM_list}  ${Slave_dedicated_RM_list}=
    ...  Admin Get Shared And Dedicated RM List for Master and Slave  Master  Slave
    ${Master_shared_RM_CELL_list}=  Create List
    FOR  ${item}  IN  @{Master_shared_RM_list}
        ${Master_CELL_RM_list}=  Get Cell Mapping By Module Id  module_id=${item}  alias=Master
        Append To List  ${Master_shared_RM_CELL_list}  @{Master_CELL_RM_list}
    END
    ${Master_dedicated_RM_CELL_list}=  Create List
    FOR  ${item}  IN  @{Master_dedicated_RM_list}
        ${Master_CELL_RM_list}=  Get Cell Mapping By Module Id  module_id=${item}  alias=Master
        Append To List  ${Master_dedicated_RM_CELL_list}  @{Master_CELL_RM_list}
    END
    ${Master_shared_RM_CELL_list}=  Remove Duplicates  ${Master_shared_RM_CELL_list}
    ${Master_dedicated_RM_CELL_list}=  Remove Duplicates  ${Master_dedicated_RM_CELL_list}
    ${CELL_not_remapped_count}=  get length  ${Master_dedicated_RM_CELL_list}
    ${MASTER_EXPECTED_ALARMS_DSS_FULL}=  Prepare expected alarms list  ${MASTER_EXPECTED_ALARMS_DSS}  ${CELL_not_remapped_count}
    Set Test Variable  ${MASTER_EXPECTED_ALARMS_DSS_FULL}
    ${MASTER_EXPECTED_ALARMS_RMOD_DSS_FULL}=  Create List  @{EMPTY}
    Append To List  ${MASTER_EXPECTED_ALARMS_RMOD_DSS_FULL}  @{MASTER_EXPECTED_ALARMS_RMOD_FULL}
    Append To List  ${MASTER_EXPECTED_ALARMS_RMOD_DSS_FULL}  @{MASTER_EXPECTED_ALARMS_DSS_FULL}
    Set Test Variable  ${MASTER_EXPECTED_ALARMS_RMOD_DSS_FULL}

Check Cells State
    [Arguments]  ${CELL_class}  ${CELL_list}  ${states}  ${timeout}  ${alias}
    FOR  ${item}  IN  @{CELL_list}
        Assert  ${CELL_class}  ${item}  ${states}  timeout=${timeout}  alias=${alias}
    END

Check RMOD L3 Protocol
    [Arguments]  ${alias}
    Set Test Variable  ${RMOD_L3Protocol}  None
    ${RMOD_L3Protocol_dict}=  Admin Get RMOD L3 Protocol Info  ${alias}
    ${RMOD_L3Protocol_values}=  Get Dictionary Values  ${RMOD_L3Protocol_dict}
    ${RMOD_L3Protocol_value}=  Remove Duplicates  ${RMOD_L3Protocol_values}
    Run Keyword If  len(${RMOD_L3Protocol_value}) == 1  Set Test Variable  ${RMOD_L3Protocol}  ${RMOD_L3Protocol_value[0]}
    ...  ELSE  Return From Keyword
    ${NR_Shared_RM_CELL_list}=  Get NR cell list from shared RM
    Set Test Variable    ${NR_Shared_RM_CELL_list}
    ${NR_Shared_RM_CELL_count}=  Get Length  ${NR_Shared_RM_CELL_list}
    Set Test Variable  ${NR_alarm_count}  ${NR_Shared_RM_CELL_count}

Get NR cell list from shared RM
    ${Master_shared_RM_CELL_list}=  Create List
    FOR  ${item}  IN  @{Master_shared_RM_list}
        ${Master_CELL_RM_list}=  Get Cell Mapping By Module Id  module_id=${item}  alias=Master
        Append To List  ${Master_shared_RM_CELL_list}  @{Master_CELL_RM_list}
    END
    ${Master_shared_RM_CELL_list}=  Remove Duplicates  ${Master_shared_RM_CELL_list}
    [Return]  ${Master_shared_RM_CELL_list}

Particular Teardown
    Recover BTS SMs PDU port status  ${Slave_SM_PDU_if_name_list}  on  Slave
    Export KPI results to File Global  kpi_log_file_name=KpiTimeInfo

TC Setup
    ${tech_preset_list}=  Create List  SBTS  SBTS
    Common Test Setup  preset_techs=${tech_preset_list}  common_sbts=${TRUE}  infomodelSetup=${FALSE}

TC Teardown
    Common Test Teardown
