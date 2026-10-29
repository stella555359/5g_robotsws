*** Settings ***
Documentation    TC__NRL__CM__Planned_Recommissioning_LTE_template
Variables    tc_variables/nrl__cm__planned_recommissioning_lte_template.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${BTS_PRIMARY_LINK}                  # BTS primary link set before LTE Recommissioning, possible values: empty (no set required),
                                     # Master (Master set required) or Slave (Slave set required); default value: empty
${SET_PRIMARY_LINK_TIME}       720   # Maximum time in seconds to wait for Primary Link set on ${BTS_PRIMARY_LINK}, default value: 720
${SET_PRIMARY_LINK_PROCEDURE}  LANE  # Procedure for setting BTS_PRIMARY_LINK, possible values: BTS (BTS Reset), LANE (Lock Unlock SFP LANE)
${RECOMMISSIONING_LTE}         NONE  # Absolute path for SCF file with commissioning for LTE RAT (i.e. /home/ute/btsauto/SCF_01_SBTS19.xml).
                                     # If NONE, current SCF will be used
${REPEAT_COUNTER}              3     # Number of LTE Recommissioning operations, default value 3
${RESET_CONFIGURATION}         True  # Flag to enable/disable LTE Reset configuration before recommissioning, can be True/False; default value True
${LTE_SCF_VALIDATION}          True  # Validate LTE SCF; can be True or False
${CELLS_CHECK_INTERVAL}        360   # Time interval for last cells check
${VERDICT_WRONG_LTE_RESET_NUMBER}  PASS   # The test verdict in case of wrong LTE Reset Number. Values: PASS(passed with restriction) or FAIL(Cloud)

*** Keywords ***
TC__NRL__CM__Planned_Recommissioning_LTE_template
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-17500
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  NR-LTE test case for Planned_Recommissioning_LTE_template, - x times sequence.
    ...  x - value of REPEAT_COUNTER parameter (default: 3)
    ...  The main steps performed for the test are:
    ...  - check initial state and alarms for both NR and LTE technologies
    ...  - set if needed primary CPRI on requested technology
    ...  - LTE reset configuration
    ...  - Planned Recommissioning LTE with SCF file
    ...  - check reset behavior on NR and LTE based on IMS info as follows:
    ...    - NR site: reset number is 0
    ...    - LTE site: reset number is 2 if RESET_CONFIGURATION=True else reset number is 1
    ...  - check final state and alarms for both NR and LTE technologies
    ...  Pass criteria: Planned Recommissioning operation works as expected, states and alarms are as expected
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 15.10.2019 - https://jiradc.ext.net.nokia.com/browse/TAT-17500 -
    ...  [NR][P19]Create new automated test Planned_Re-Comissioning_LTE_template_LTE_primary_x3
    ...  - 14.11.2019 - https://jiradc.ext.net.nokia.com/browse/TAT-18116 - CPRI primary set for TDD RM : robot TC enhancement
    ...  - 08.01.2020 - https://jiradc.ext.net.nokia.com/browse/TAT-18700 - Add CONFIG RESET operation in Planned_Recommissioning scenarios
    ...  - 12.02.2020 - https://jiradc.ext.net.nokia.com/browse/TAT-18966 - Increase Timeout for Keywords related to Reset behaviour
    ...  - 17.02.2020 - https://jiradc.ext.net.nokia.com/browse/TAT-18983 -
    ...  Check if parameter actCategoryAlarms is false/true for NRL__STATE__NR_RM_LockUnlock_from_WEBEM
    ...  - 03.02.2020 - https://jiradc.ext.net.nokia.com/browse/TAT-19108 - Add primary CPRI link check and SW Build check after config reset
    ...  - 24.04.2020 - https://jiradc.ext.net.nokia.com/browse/TAT-19366 - Implement cells check interval in NRL and NR-SBTS TCs where it is needed
    ...  - 02.06.2020 - https://jiradc.ext.net.nokia.com/browse/TAT-19386 - NRL  planned recommissioning tests dryrun failure
    ...  - 23.07.2020 - https://jiradc.ext.net.nokia.com/browse/TAT-19956 -
    ...  Refactor tests using "Set RMOD CPRI Primary Status" to provide Master/Slave argument to KW instead of NR/LTE
    ...  - 13.10.2020 - https://jiradc.ext.net.nokia.com/browse/TAT-20237 - Add CPRI primary link check functionality for new TDD RU AWHHF/D
    ...  - 21.10.2020 - https://jiradc.ext.net.nokia.com/browse/TAT-20324 - [Refactoring] Optimize Repeat_Counter loop in test cases - NRL
    ...  - 03.11.2020 - https://jiradc.ext.net.nokia.com/browse/TAT-20427 - Variable CYCLE not found
    ...  - 18.03.2021 - https://jiradc.ext.net.nokia.com/browse/TAT-20864 - [Legacy] Pipeline: Clean up robot TC in RFS_SOAM folder - NRL
    ...  - 16.03.2021 - https://jiradc.ext.net.nokia.com/browse/TAT-19342 - Modify SOAM test cases to use tunnel mechanism from TAT-19182
    ...  - 10.05.2021 - https://jiradc.ext.net.nokia.com/browse/TAT-21302 -
    ...  [Legacy][taf.sbts.oam.coam.admin] Update import in resources, update & test TC LG, MTNRL
    ...  - 30.06.2021 - https://jiradc.ext.net.nokia.com/browse/TAT-21401 -
    ...  [Legacy] taf.sbts.oam.coam.admin refactoring for collect_scf -> get_current_scf_file
    ...  - 03.09.2021 - https://jiradc.ext.net.nokia.com/browse/TAT-21804 - [5G] Refactoring due to stateInfo changes: NRL
    ...  - 18.10.2021 - https://jiradc.ext.net.nokia.com/browse/TAT-21198
    ...  - [5G][MT][eCPRI] Enhancement for NRL__CM__Planned_Recommissioning_NR_template
    ...  and NRL__CM__Planned_Recommissioning_LTE_template - Make Configuration reset optional
    ...  - 06.01.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-21775 - [5G][Legacy][RFSplit] Test NRL Common Part (hran_ta)
    ...  - 19.01.2021 - https://jiradc.ext.net.nokia.com/browse/TAT-22480 - [5G][PrimaryLink][P3] NRL_CM_ , tests
    ...  Use 'Set Primary Link status based on linkModeSynchronization'
    ...  - 28.02.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-22675 -[5G] Wait for Notcommisssioned state after LTE configuration
    ...  reset in NRL__CM__Planned_Recommissioning_LTE_template
    ...  - 15.03.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-22791 - [5G] Allow user to set expected reset number
    ...  for NRL__CM__Planned_Recommissioning_NR_template, NRL__CM__Planned_Recommissioning_LTE_template
    ...  - 19.04.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-22959 - [5G] Remove timeout from NR planned
    ...  recommissioning and LTE planned recommissioning
    ...  - 30.06.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23334 - [5G] Remove connection_type=ssh_tunnel parameter from
    ...  NR/NR_SBTS__CM__Planned_Recommissioning_LTE_template
    ...  - 12.09.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23368 -
    ...  [Cloud][Pilot robotws][PyLibraries] Drop "hran-tools" library KWs used by RFS TCs
    ...  - 03.10.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23748 -
    ...  [5G] NRL__CM__Planned_Recommissioning_NR_template is Recommisioning NR side with LTE scf
    ...  - 03.02.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-23335 - [5G] Need additional alarms checks during BTS commissioning to change
    ...  parameter implying reset - NRL
    ...  - 16.02.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24698 - [5G][Reset Number ims2] Update NRL CM ... scenarios to take reset
    ...  number from ims2 - P2
    ...  - 16.05.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24838 - [5G][CB007500] New behavior in Configuration Reset - NRL -> action on LTE
    ...  - 04.07.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25653 - [5G] Check of FID7509 to be included in NRL TestCases in checks on NR,
    ...  when LTE DSS partners are not available
    ...  - 02.08.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25491 - [5G][CB007500] Peer checks during Reset Configuration should be removed
    ...  - 18.06.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-27664 -
    ...  [5G] [SCF check] - P0 - NRL- Include SCF validation with hardware check in CM Tests
    ...  - 16.09.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29822 -
    ...  Unify alarm list names in order alarm list to begin with upper case Alias - NRL
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...  .. image:: https://gitlabe1.ext.net.nokia.com/panda-docs/hran_doc/-/blob/master/testsuite/RFS_SOAM/
    ...  TAT-17500_NRL__CM__Planned_Recommissioning_LTE_template.png


    Set Tags    CA-CM    OWNER-bogdan.vinereanu@nokia.com    AUTHOR-gabriel.stanculescu@nokia.com    PHASE-QT
    ...    SW-5G19,SBTS19

    Primary Link TC Parameter Check
    TC Parameters check
    Step 1: Check initial all BTS state
    Step 2: Check initial all BTS alarms
    FOR  ${INDEX}  IN RANGE  1  ${REPEAT_COUNTER}+1
        Log  ==============================================================================  console=True
        Log  Start Cycle ${INDEX} of ${REPEAT_COUNTER}  console=True
        Log  ==============================================================================  console=True
        Set Shared RMOD Primary Link
        Step 3: Get initial date UTC info
        Run Keyword If  '${RESET_CONFIGURATION}' == 'True'  Run Keywords
        ...  Step 6: LTE Reset Configuration
        ...  AND  Check NR and LTE reset behavior after LTE Reset Configuration based on IMS info
        ...  ELSE  Log  Step 6: LTE Reset Configuration will be skipped  console=True
        Step 4: Planned LTE Recommissioning
        Step 5: Check final all BTS state
        Step 6: Check final all BTS alarms
        Step 7: Get final date UTC info
        Step 8: Check NR and LTE reset behavior based on IMS info
        Step 9: Check final number and state of Cells and RMs
    END

TC Parameters check
    ${scf_path_tmp}=  Run Keyword If  '${RECOMMISSIONING_LTE}' == 'NONE'
    ...  Admin Collect scf.xml with timestamp TAF  alias=Slave  folder_path=${BTSFiles}/Slave
    ...  ELSE  Set Variable  ${RECOMMISSIONING_LTE}
    OperatingSystem.File Should Exist  ${scf_path_tmp}
    ${bts_info_tmp}=  Admin Get BTS state info  alias=Slave
    Set Test Variable  ${lte_commissioning_scf_path}  ${scf_path_tmp}
    Set Test Variable  ${bts_info}  ${bts_info_tmp}

Set Shared RMOD Primary Link
    [Documentation]
    ...  Set shared RMOD Primary Link if needed

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
    ...  procedure_for_Primary_Link_set=${SET_PRIMARY_LINK_PROCEDURE}  alias=${BTS_PRIMARY_LINK}  wait_for_Primary_Link_set=${SET_PRIMARY_LINK_TIME}

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

Step ${index}: Get ${when} date UTC info
    Log  Step ${index}: Get ${when} date UTC info  console=True
    Get Current Date UTC info  ${when}

Step ${index}: LTE Reset Configuration
    [Documentation]
    ...  Detect needed LTE SCF and reset LTE configuration
    ...  If SCF is not specified in RECOMMISSIONING_LTE, will download the current SCF and use it

    [Timeout]  20 min
    Log  Step ${index}: LTE Reset Configuration  console=True
    Log  TC does not check FID10 during Configuration Reset  console=True

    Reset BTS Configuration TAF  connection=Slave  wait_for_admin_connection=True  remove_operator_certificates=False
    ...  remove_user_account_credentials=True  repair_center_reset=True

    Wait For Target To Be Reachable TAF  hostname=${SLAVE['SLAVE_TECH_IP_ADDRESS']}  timeout=250  remote_host=${SLAVE['SLAVE_PC_IP_ADDRESS']}
    Log  LTE SM (${SLAVE['SLAVE_TECH_IP_ADDRESS']} from localhost) has been reachable within 250 seconds  console=True
    Wait Until Keyword Succeeds  8 min  1 min  Uncommission module status LTE SOAM
    Log  LTE Reset Configuration completed!  console=True

    Get Current Date UTC info  end_reset

Check NR and LTE reset behavior after LTE Reset Configuration based on IMS info
    [Documentation]
    ...  BTS RESET info is checked based on IMS info. Reset behavior as expected if:
    ...  - NR site: reset number is 0
    ...  - LTE site: reset number is 1
    ...  Otherwise, reset behavior not as expected, then errors are added to report and failed.

    Log  Check NR and LTE reset behavior after LTE Reset Configuration based on IMS info  console=True

    ${log_level}=  Set Variable If  '${VERDICT_WRONG_LTE_RESET_NUMBER}' == 'PASS'  WARN  ERROR
    Get and check BTS RESET info from IMS file  expected_reset_number=0  alias=Master
    ...  start_point_timestamp_UTC=${date_timestamp_initial_UTC}  end_point_timestamp_UTC=${date_timestamp_end_reset_UTC}  remove_ims_file=False
    Get and check BTS RESET info from IMS file  expected_reset_number=1  alias=Slave
    ...  start_point_timestamp_UTC=${date_timestamp_initial_UTC}  end_point_timestamp_UTC=${date_timestamp_end_reset_UTC}  remove_ims_file=False
    ...  log_level=${log_level}

Uncommission module status LTE SOAM
    [Documentation]
    ...  Checks procedural state of BTS LTE SOAM Slave

    ${BTS state}=  coam.Get Mrbts State  timeout=600  alias=Slave
    Log  BTS proceduralState is: ${BTS state}  console=True
    Should Contain  ${NotCommissioned_}  ${BTS state}

Check SW configuration did not change
    [Documentation]
    ...  Extract Master and Slave active and passive SWs using Admin and compare to initial values. Fail if something changed

    ${current_active_SW_Master}  ${current_passive_SW_Master}=  Wait Until Keyword Succeeds  5m  20s  Admin Get BTS SW Version  Master
    ${current_active_SW_Slave}  ${current_passive_SW_Slave}=  Wait Until Keyword Succeeds  5m  20s  Admin Get BTS SW Version  Slave
    ${initial_SW_list}=  Create List  ${Master active SW}  ${Master passive SW}  ${Slave active SW}  ${Slave passive SW}
    ${current_SW_list}=  Create List  ${current_active_SW_Master}  ${current_passive_SW_Master}
    ...  ${current_active_SW_Slave}  ${current_passive_SW_Slave}
    ${no_sw_change}=  Run Keyword And Return Status  Should Be Equal  ${initial_SW_list}  ${current_SW_list}
    Run Keyword If  not ${no_sw_change}  Run Keywords
    ...  Log Long String  SW configuration changed! Master SW active/passive: ${current_active_SW_Master}/${current_passive_SW_Master};
    ...  Slave SW active/passive: ${current_active_SW_Slave}/${current_passive_SW_Slave}  console=True
    ...  AND  Fail  SW configuration changed!

Step ${index}: Planned LTE Recommissioning
    [Documentation]
    ...  Planned LTE recommissioning with SCF file is triggered. The new SCF file is loaded on LTE SM and a reboot should be triggered after

    Log  Step ${index}: Planned LTE Recommissioning  console=True
    Log  Commissioning via ADMIN will be performed using ${lte_commissioning_scf_path}  console=True
    coam.Perform Commissioning  bts_id=${bts_info[0]}  scf_file=${lte_commissioning_scf_path}  skip_parameter_relation_errors=True
    ...  should_activate=True  timeout=400  alias=Slave

    Log  LTE commissioning has been performed  console=True

    Get Current Time  lte_initial

    Run Keyword If  ${LTE_SCF_VALIDATION}  Check BTS SCF Validation On Demand  alias=Slave

    Check SW configuration did not change

Step ${index}: Check NR and LTE reset behavior based on IMS info
    [Documentation]
    ...  BTS RESET info is checked based on IMS info. Reset behavior as expected if:
    ...  - NR site: reset number is 0
    ...  - LTE site: reset number is 2 if RESET_CONFIGURATION=True else reset number is 1
    ...  Otherwise, reset behavior not as expected, then errors are added to report and failed.

    Log  Step ${index}: Check NR and LTE reset behavior based on IMS info  console=True

    ${log_level}=  Set Variable If  '${VERDICT_WRONG_LTE_RESET_NUMBER}' == 'PASS'  WARN  ERROR
    Get and check BTS RESET info from IMS file  expected_reset_number=0  alias=Master
    ...  start_point_timestamp_UTC=${date_timestamp_initial_UTC}  end_point_timestamp_UTC=${date_timestamp_final_UTC}  remove_ims_file=False

    Run Keyword and Continue on Failure  Run Keyword If  '${RESET_CONFIGURATION}' == 'True'
    ...  Get and check BTS RESET info from IMS file  expected_reset_number=2  alias=Slave
    ...  start_point_timestamp_UTC=${date_timestamp_initial_UTC}  end_point_timestamp_UTC=${date_timestamp_final_UTC}  remove_ims_file=False
    ...  log_level=${log_level}
    ...  ELSE IF  '${RESET_CONFIGURATION}' == 'False'
    ...  Get and check BTS RESET info from IMS file  expected_reset_number=1  alias=Slave
    ...  start_point_timestamp_UTC=${date_timestamp_initial_UTC}  end_point_timestamp_UTC=${date_timestamp_final_UTC}  remove_ims_file=False
    ...  log_level=${log_level}

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]
    ...  Following checks are performed:
    ...  - number of configured cells and radio modules in SCF are properly mapped on BTS running view ADMIN
    ...  - check cells states
    ...  - check radio modules states

    Log  Step ${index}: Check final number and state of Cells and RMs  console=True
    Get Current Time  before_cell_check
    ${elapsed_time_before_cell_check}=  DateTime.Subtract Date From Date  ${time_before_cell_check}  ${time_lte_initial}  number
    ${remained_time}=  BuiltIn.Evaluate  ${CELLS_CHECK_INTERVAL}-${elapsed_time_before_cell_check}
    Run Keyword If  ${remained_time}>0  Run Keywords
    ...  Log  Time interval for Cells check: ${CELLS_CHECK_INTERVAL} sec -> Wait ${remained_time} sec  console=True
    ...  AND  Sleep  ${remained_time} sec
    RFS Test Case Final Checks

TC Setup
    ${tech_preset_list}=  Create List  SBTS  SBTS
    Common Test Setup  preset_techs=${tech_preset_list}  common_sbts=${TRUE}  infomodelSetup=${FALSE}

TC Teardown
    Common Test Teardown
