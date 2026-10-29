*** Settings ***
Documentation    TC__NR_SBTS__CM__Planned_Recommissioning_SBTS_template
Variables    tc_variables/nr_sbts__cm__planned_recommissioning_sbts_template_alarm_definitions.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${BTS_PRIMARY_LINK}                      # BTS primary link set before SBTS Recommissioning, possible values: empty (no set required),
                                         # Master (Master set required) or Slave (Slave set required); default value: empty
${SET_PRIMARY_LINK_TIME}       720       # Maximum time in seconds to wait for Primary Link set on ${BTS_PRIMARY_LINK}, default value: 720
${SET_PRIMARY_LINK_PROCEDURE}  LANE      # Procedure for setting BTS_PRIMARY_LINK, possible values: BTS (BTS Reset), LANE (Lock Unlock SFP LANE)
${RECOMMISSIONING_SBTS}       NONE       # Absolute path for SCF file with commissioning for SBTS RAT (i.e. /home/ute/btsauto/SCF_01_SBTS19.xml).
                                         # If NONE, current SCF will be used
${REPEAT_COUNTER}             3          # Number of SBTS Recommissioning operations, default value 3
${SBTS_SCF_VALIDATION}        True       # Validate SBTS SCF; can be True or False
${CELLS_CHECK_INTERVAL}       360        # Time interval for last cells check
${VERDICT_WRONG_SBTS_RESET_NUMBER}  PASS   # The test verdict in case of wrong SBTS Reset Number.Values: PASS(passed with restriction) or FAIL(Cloud)

*** Keywords ***
TC__NR_SBTS__CM__Planned_Recommissioning_SBTS_template
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-19560
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  NR-SBTS test case for Planned_Recommissioning_SBTS_template, - x times sequence.
    ...  x - value of REPEAT_COUNTER parameter (default: 3)
    ...  The main steps performed for the test are:
    ...  - check initial state and alarms for both NR and SBTS technologies
    ...  - set if needed shared RMOD primary link on requested technology
    ...  - SBTS reset configuration
    ...  - Planned Recommissioning SBTS with SCF file
    ...  - check reset behavior on NR and SBTS based on IMS info as follows:
    ...    - NR site: reset number is 0
    ...    - SBTS site: reset number is 2
    ...  - check final state and alarms for both NR and SBTS technologies
    ...  Pass criteria: Planned Recommissioning operation works as expected, states and alarms are as expected
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 05.06.2020 - https://jiradc.ext.net.nokia.com/browse/TAT-19560 - NR_SBTS__CM__Planned_Recommissioning_NR_template delivery
    ...  - 23.07.2020 - https://jiradc.ext.net.nokia.com/browse/TAT-19956 -
    ...  Refactor tests using "Set RMOD CPRI Primary Status" to provide Master/Slave argument to KW instead of NR/LTE
    ...  - 02.10.2020 - https://jiradc.ext.net.nokia.com/browse/TAT-20236 -
    ...  [NR SBTS DSS] Enhancement should be done for NR SBTS tests for DSS OBSAI/CPRI configurations related to commissioning/recommissioning
    ...  - 13.10.2020 - https://jiradc.ext.net.nokia.com/browse/TAT-20237 - Add CPRI primary link check functionality for new TDD RU AWHHF/D
    ...  - 14.10.2020 - https://jiradc.ext.net.nokia.com/browse/TAT-20319 - [Refactoring] Optimize Repeat_Counter loop in test cases - NR-SBTS
    ...  - 23.03.2021 - https://jiradc.ext.net.nokia.com/browse/TAT-20865 - [Legacy] Pipeline: Clean up robot TC in RFS_SOAM folder - NR_SBTS
    ...  - 06.04.2021 - https://jiradc.ext.net.nokia.com/browse/TAT-2137 -
    ...  [NR][SBTS]NR_SBTS__CM__Planned_Recommissioning_SBTS_template test must be updated
    ...  - 16.03.2021 - https://jiradc.ext.net.nokia.com/browse/TAT-19342 - Modify SOAM test cases to use tunnel mechanism from TAT-19182
    ...  - 12.05.2021 - https://jiradc.ext.net.nokia.com/browse/TAT-21303 - [Legacy][taf.sbts.oam.coam.admin] Udate & test TC NR_SBTS
    ...  - 30.06.2021 - https://jiradc.ext.net.nokia.com/browse/TAT-21401 -
    ...  [Legacy] taf.sbts.oam.coam.admin refactoring for collect_scf -> get_current_scf_file
    ...  - 14.09.2021 - https://jiradc.ext.net.nokia.com/browse/TAT-21804 - [5G] Refactoring due to stateInfo changes: NR_SBTS
    ...  - 14.01.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-21776 - [5G][Legacy][RFSplit] Test NRSBTS Common Part (hran_ta)
    ...  - 31.01.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-22481 - [5G][PrimaryLink] [P4] NR_SBTS__SWM__, NR_SBTS__CM__,TCs refactor to use
    ...                                                                    'hran_general.Set Primary Link status based on linkModeSynchronization'
    ...  - 09.03.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-22704 - [5G] Wait for Notcommisssioned state after SBTS configuration reset
    ...                                                                    in NR_SBTS__CM__Planned_Recommissioning_SBTS_template
    ...  - 14.03.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-22784 - [5G] NR_SBTS__CM__Planned_Recommissioning_SBTS_template
    ...  - 30.06.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23334 - [5G] Remove connection_type=ssh_tunnel parameter from
    ...  NR/NR_SBTS__CM__Planned_Recommissioning_LTE_template
    ...  - 12.09.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23368 -
    ...  [Cloud][Pilot robotws][PyLibraries] Drop "hran-tools" library KWs used by RFS TCs
    ...  - 29.09.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23684 -
    ...  [5G]Remove timeout from NR planned recommissioning - NR-SBTS Recomissioning TCs
    ...  - 03.10.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23748
    ...  [5G] NRL__CM__Planned_Recommissioning_NR_template is Recommisioning NR side with LTE scf
    ...  - 08.02.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-23430 - [5G] Need additional alarms checks during BTS commissioning to change
    ...  parameter implying reset - NR-SBTS
    ...  - 21.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24881 - [5G][Reset Number ims2] Update NR-SBTS CM scenarios to take reset
    ...  number from ims2 - P2
    ...  - 19.05.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25330 - [5G][CB007500] New behaviour for Configuration Reset from WEBEM - NR_SBTS
    ...  -> action on SBTS
    ...  - 04.07.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25652 - [5G]Check of FID7509 to be included in NR_SBTS TestCases
    ...  - 14.07.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25747 - [5G] NR_SBTS__CM__Planned_Recommissioning_SBTS_template fails with
    ...  Variable '${VERDICT_WRONG_NR_RESET_NUMBER}' not found
    ...  - 02.08.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25491 - [5G][CB007500] Peer checks during Reset Configuration should be removed
    ...  - 24.10.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29823 -
    ...  Unify alarm list names in order alarm list to begin with upper case Alias - NR_SBTS
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...  .. image:: https://gitlabe1.ext.net.nokia.com/panda-docs/hran_doc/-/blob/master/testsuite/RFS_SOAM/
    ...  TAT-19560_NR_SBTS__CM__Planned_Recommissioning_SBTS_template.png

    Set Tags    CA-CM    OWNER-marius.roman@nokia.com    AUTHOR-gabriel.stanculescu@nokia.com    PHASE-QT
    ...    SW-5G19,SBTS19

    Primary Link TC Parameter Check
    Step 1: Check initial all BTS state
    Step 2: Check initial all BTS alarms
    FOR  ${INDEX}  IN RANGE  1  ${REPEAT_COUNTER}+1
        Log  ==============================================================================  console=True
        Log  Start Cycle ${INDEX} of ${REPEAT_COUNTER}  console=True
        Log  ==============================================================================  console=True
        Step 3: Set Shared RMOD Primary Link before Planned SBTS Recommissioning operation
        Step 4: Get initial date UTC info
        Step 5: SBTS Reset Configuration
        Step 6: Planned SBTS Recommissioning
        Step 7: Check final all BTS state
        Step 8: Check final all BTS alarms
        Step 9: Get final date UTC info
        Step 10: Check NR and SBTS reset behavior based on IMS info
        Step 11: Check final number and state of Cells and RMs
    END

Step ${index}: Set Shared RMOD Primary Link before Planned SBTS Recommissioning operation
    [Documentation]
    ...  Set shared RMOD Primary Link if needed

    Log  Step ${index}: Set shared RMOD Primary Link before Planned SBTS Recommissioning operation  console=True
    Run Keyword If  '${BTS_PRIMARY_LINK}' == ''  Run Keywords
    ...  Highlight Log  Test action will be performed with existing Primary Link configuration
    ...  AND  Return From Keyword
    ...  ELSE IF  '${BTS_PRIMARY_LINK}' in ['Master','Slave']  Run Keywords
    ...  Highlight Log  Test action will be performed with Primary Link set on BTS ${BTS_PRIMARY_LINK}
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

Step ${index}: SBTS Reset Configuration
    [Documentation]
    ...  Detect needed SBTS SCF and reset SBTS configuration
    ...  If SCF is not specified in RECOMMISSIONING_SBTS, will download the current SCF and use it
    Log  Step ${index}: SBTS Reset Configuration  console=True
    Log  TC does not check FID10 during Configuration Reset  console=True

    ${scf_path_tmp}=  Run Keyword If  '${RECOMMISSIONING_SBTS}' == 'NONE'
    ...  Admin Collect scf.xml with timestamp TAF  alias=Slave  folder_path=${BTSFiles}/Slave
    ...  ELSE  Set Variable  ${RECOMMISSIONING_SBTS}
    OperatingSystem.File Should Exist  ${scf_path_tmp}
    ${bts_info_tmp}=  Admin Get BTS state info  alias=Slave
    Set Test Variable  ${sbts_commissioning_scf_path}  ${scf_path_tmp}
    Set Test Variable  ${bts_info}  ${bts_info_tmp}

    Reset BTS Configuration TAF  connection=Slave  wait_for_admin_connection=True  remove_operator_certificates=False
    ...  remove_user_account_credentials=True  repair_center_reset=True

    Wait For Target To Be Reachable TAF  hostname=${SLAVE['SLAVE_TECH_IP_ADDRESS']}  timeout=200  remote_host=${SLAVE['SLAVE_PC_IP_ADDRESS']}
    Log  SBTS SM (${SLAVE['SLAVE_TECH_IP_ADDRESS']} from localhost) has been reachable within 200 seconds  console=True
    Wait Until Keyword Succeeds  5 min  1 min  Uncommission module status SBTS
    Log  SBTS Reset Configuration completed!  console=True
    Get Current Date UTC info  end_reset
    Check NR and SBTS reset behavior after SBTS Reset Configuration based on IMS info

Check NR and SBTS reset behavior after SBTS Reset Configuration based on IMS info
    [Documentation]
    ...  BTS RESET info is checked based on IMS info. Reset behavior as expected if:
    ...  - NR site: reset number is 0
    ...  - SBTS site: reset number is 1
    ...  Otherwise, reset behavior not as expected, then errors are added to report and failed.

    Log  Check NR and SBTS reset behavior after SBTS Reset Configuration based on IMS info  console=True

    ${log_level}=  Set Variable If  '${VERDICT_WRONG_SBTS_RESET_NUMBER}' == 'PASS'  WARN  ERROR
    Get and check BTS RESET info from IMS file  expected_reset_number=0  alias=Master
    ...  start_point_timestamp_UTC=${date_timestamp_initial_UTC}  end_point_timestamp_UTC=${date_timestamp_end_reset_UTC}  remove_ims_file=False
    Get and check BTS RESET info from IMS file  expected_reset_number=1  alias=Slave
    ...  start_point_timestamp_UTC=${date_timestamp_initial_UTC}  end_point_timestamp_UTC=${date_timestamp_end_reset_UTC}  remove_ims_file=False
    ...  log_level=${log_level}

Uncommission module status SBTS
    [Documentation]
    ...  Checks procedural state of SBTS Slave

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

Step ${index}: Planned SBTS Recommissioning
    [Documentation]
    ...  Planned SBTS recommissioning with SCF file is triggered. The new SCF file is loaded on SBTS SM and a reboot should be triggered after

    Log  Step ${index}: Planned SBTS Recommissioning  console=True

    Log  Commissioning via ADMIN will be performed using ${sbts_commissioning_scf_path}  console=True
    coam.Perform Commissioning  bts_id=${bts_info[0]}  scf_file=${sbts_commissioning_scf_path}  skip_parameter_relation_errors=True
    ...  should_activate=True  timeout=400  alias=Slave
    Log  SBTS commissioning has been performed  console=True

    Get Current Time  sbts_initial

    Run Keyword If  ${SBTS_SCF_VALIDATION}  Run Keywords
    ...  Log  Validate SBTS SCF after Recommissioning  console=True
    ...  AND  Admin Validate SCF TAF  alias=Slave
    ...  AND  Admin Validate SCF With Detected Hardware  alias=Slave

    Check SW configuration did not change

Step ${index}: Check NR and SBTS reset behavior based on IMS info
    [Documentation]
    ...  BTS RESET info is checked based on IMS info for both NR and SBTS. Reset behavior as expected if:
    ...  - NR site: reset number is 0
    ...  - SBTS site: reset number is 2
    ...  Otherwise, reset behavior not as expected, then errors are added to report and failed.

    Log  Step ${index}: Check NR and SBTS reset behavior based on IMS info  console=True

    ${log_level}=  Set Variable If  '${VERDICT_WRONG_SBTS_RESET_NUMBER}' == 'PASS'  WARN  ERROR
    Get and check BTS RESET info from IMS file  expected_reset_number=0  alias=Master  remove_ims_file=False
    ...  start_point_timestamp_UTC=${date_timestamp_initial_UTC}  end_point_timestamp_UTC=${date_timestamp_final_UTC}
    Get and check BTS RESET info from IMS file  expected_reset_number=2  alias=Slave  remove_ims_file=False
    ...  start_point_timestamp_UTC=${date_timestamp_initial_UTC}  end_point_timestamp_UTC=${date_timestamp_final_UTC}  log_level=${log_level}

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]
    ...  Following checks are performed:
    ...  - number of configured cells and radio modules in SCF are properly mapped on BTS running view ADMIN
    ...  - check cells states
    ...  - check radio modules states

    [Timeout]  30 min
    Log  Step ${index}: Check final number and state of Cells and RMs  console=True
    Get Current Time  before_cell_check
    ${elapsed_time_before_cell_check}=  DateTime.Subtract Date From Date  ${time_before_cell_check}  ${time_sbts_initial}  number
    ${remained_time}=  BuiltIn.Evaluate  ${CELLS_CHECK_INTERVAL}-${elapsed_time_before_cell_check}
    Run Keyword If  ${remained_time}>0  Run Keywords
    ...  Log  Time interval for Cells check: ${CELLS_CHECK_INTERVAL} sec -> Wait ${remained_time} sec  console=True
    ...  AND  Sleep  ${remained_time} sec
    RFS Test Case Final Checks  wait_timer=18 min

TC Setup
    ${tech_preset_list}=  Create List  SBTS  SBTS
    Common Test Setup  preset_techs=${tech_preset_list}  common_sbts=${TRUE}  connection_type=ssh_tunnel  infomodelSetup=${FALSE}

TC Teardown
    Common Test Teardown
