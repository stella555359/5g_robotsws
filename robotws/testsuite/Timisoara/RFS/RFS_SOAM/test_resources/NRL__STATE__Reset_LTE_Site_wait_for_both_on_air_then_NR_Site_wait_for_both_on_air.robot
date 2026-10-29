*** Settings ***
Documentation    TC__NRL__STATE__Reset_LTE_Site_wait_for_both_on_air_then_NR_Site_wait_for_both_on_air
Variables    tc_variables/nrl__state__reset_lte_site_wait_for_both_on_air_then_nr_site_wait_for_both_on_air.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${REPEAT_COUNTER}        3      # Number of NR and LTE BTS reset operations, default value 3
${NR_RESET_WRN_THR}      540    # Compared with the time spent between first cell down and last cell up.
                                # If exceeds NR_RESET_WRN_THR, test verdict passed with restriction and snapshot collected.
                                # Default value: in accordance with KPI 1a specifications
${LTE_RESET_WRN_THR}     606    # If LTE Reset exceeds LTE_RESET_WRN_THR, test verdict passed with restriction and snapshot at the end of the test.
${NR_MAX_WAIT_TIME}      900    # Maximum time for wait of BTS OnAir
${LTE_MAX_WAIT_TIME}     900    # Maximum time for wait of ENB OnAir
${GRACEFUL_CELL_SHUTDOWN}  True  # Graceful cell shutdown: True or False; default value: True

*** Keywords ***
TC__NRL__STATE__Reset_LTE_Site_wait_for_both_on_air_then_NR_Site_wait_for_both_on_air
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-17417
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  NR-LTE test case for Reset_LTE_Site_wait_for_both_on_air_then_NR_Site_wait_for_both_on_air, - x times sequence.
    ...  x - value of REPEAT_COUNTER parameter (default: 3)
    ...  The main steps performed for the test are:
    ...  - check initial state and alarms for both NR and LTE technologies
    ...  - perform Reset BTS operation on LTE Slave
    ...  - check after LTE reset state and alarms for both NR and LTE technologies
    ...  - perform Reset BTS operation on NR Master
    ...  - check final state and alarms for both NR and LTE technologies
    ...  - check reset behavior on NR and LTE based on IMS info as follows:
    ...    - NR site: reset number is 1
    ...    - LTE site: reset number is 1
    ...  - check final number and state of Cells and RMs
    ...  Pass criteria: NR Reset BTS operation works as expected, states and alarms are as expected
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 17.09.2019 - https://jiradc.ext.net.nokia.com/browse/TAT-17417 -
    ...  [NR][P4]Create new automated test Reset_LTE_Site_wait_for_both_on_air_then_NR_Site_wait_for_both_on_air
    ...  - 11.10.2019 - https://jiradc.ext.net.nokia.com/browse/TAT-17852 -
    ...  Add ignored alarms with alarm ID 7220 on LTE (correction added through TAT-17506)
    ...  - 21.10.2019 - https://jiradc.ext.net.nokia.com/browse/TAT-17814 - [NR]Need to increase time for cells check
    ...  - 18.11.2019 - https://jiradc.ext.net.nokia.com/browse/TAT-18273 -
    ...  [NR] Snapshot is not collected when test is passed with restriction due to KPI value not met
    ...  - 12.02.2020 - https://jiradc.ext.net.nokia.com/browse/TAT-18966 - Increase Timeout for Keywords related to Reset behaviour
    ...  - 13.02.2020 - https://jiradc.ext.net.nokia.com/browse/TAT-18907 - Move "Get Current Time " Keywords from Test cases to a common resource
    ...  - 17.02.2020 - https://jiradc.ext.net.nokia.com/browse/TAT-18983 -
    ...  Check if parameter actCategoryAlarms is false/true for NRL__STATE__NR_RM_LockUnlock_from_WEBEM
    ...  - 08.05.2020 - https://jiradc.ext.net.nokia.com/browse/TAT-19496 - Confused log warning message for NR cells
    ...  - 07.07.2020 - https://jiradc.ext.net.nokia.com/browse/TAT-19759 -
    ...  Increase time for :KPI1a${NR_RESET_WRN_THR} KPI#3${NR_RESET_WRN_THR} for NRL and NR automated TCs
    ...  - 21.10.2020 - https://jiradc.ext.net.nokia.com/browse/TAT-20324 - [Refactoring] Optimize Repeat_Counter loop in test cases - NRL
    ...  - 25.02.2021 - https://jiradc.ext.net.nokia.com/browse/TAT-20503 - [Cloud] [NRL/SBTS] Cloud behavior Reset Time WRN threshold per Tech
    ...  - 18.03.2021 - https://jiradc.ext.net.nokia.com/browse/TAT-20864 - [Legacy] Pipeline: Clean up robot TC in RFS_SOAM folder - NRL
    ...  - 10.05.2021 - https://jiradc.ext.net.nokia.com/browse/TAT-21302 -
    ...  [Legacy][taf.sbts.oam.coam.admin] Update import in resources, update & test TC LG, MTNRL
    ...  - 03.09.2021 - https://jiradc.ext.net.nokia.com/browse/TAT-21804 - [5G] Refactoring due to stateInfo changes: NRL
    ...  - 06.01.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-21775 - [5G][Legacy][RFSplit] Test NRL Common Part (hran_ta)
    ...  - 14.02.2021 - https://jiradc.ext.net.nokia.com/browse/TAT-22640 - [Cloud] [RFSplit] [Legacy] Particular teardown refactoring - NRL part
    ...  - 02.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23886 - [5G][TC review][NRL] Remove Cells "AdministrativeState" check in all
    ...  NRL robots
    ...  - 13.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24790 - [5G][Reset Number ims2] Update NRL STATE ... scenarios to take reset
    ...  number from ims2 - P2- part2
    ...  - 26.09.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28126 - [5G] CNI : 131510 - Classical - Part 1 - Graceful cell shutdown
    ...  - 16.09.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29822 -
    ...  Unify alarm list names in order alarm list to begin with upper case Alias - NRL
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...  .. image:: https://gitlabe1.ext.net.nokia.com/panda-docs/hran_doc/-/blob/master/testsuite/RFS_SOAM/
    ...  TAT-17417_NRL__STATE__Reset_LTE_Site_wait_for_both_on_air_then_NR_Site_wait_for_both_on_air.png

    Set Tags    CA-STATE    OWNER-bogdan.vinereanu@nokia.com    AUTHOR-serban.hamza@nokia.com    PHASE-QT    SW-5G19,SBTS19

    Step 1: Check initial all BTS state
    Step 2: Check initial all BTS alarms
    FOR  ${INDEX}  IN RANGE  1  ${REPEAT_COUNTER}+1
        Log  ==============================================================================  console=True
        Log  Start Cycle ${INDEX} of ${REPEAT_COUNTER}  console=True
        Log  ==============================================================================  console=True
        Step 3: Reset LTE Site and export results for iteration ${INDEX} Slave
        Step 4: Check after LTE reset all BTS state
        Step 5: Check after LTE reset all BTS alarms
        Step 6: Reset NR Site and export results for iteration ${INDEX} Master
        Step 7: Check final all BTS state
        Step 8: Check final all BTS alarms
        Step 9: Check NR and LTE reset behavior based on IMS info
        Step 10: Check final number and state of Cells and RMs
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

Step ${index}: Reset ${tech} Site and export results for iteration ${CYCLE} ${alias}
    [Documentation]
    ...  Reset Site procedure is launched on LTE Slave. Next script is waiting 300 sec for reset end

    [Timeout]  20 min
    Log  Step ${index}: Reset ${tech} site and export results for iteration ${CYCLE}  console=True
    Get RESET timestamp info  initial  ${alias}
    Reset Site and export results for iteration  ${CYCLE}  ${tech}  ${alias}

Step ${index}: Check NR and LTE reset behavior based on IMS info
    [Documentation]
    ...  BTS RESET info is checked based on IMS info for both NR and LTE. Reset behavior as expected if:
    ...  - NR site: reset number is 1
    ...  - LTE site: reset number is 1
    ...  Otherwise, reset behavior not as expected, then errors are added to report and failed.

    Log  Step ${index}: Check NR and LTE reset behavior based on IMS info  console=True
    Get RESET timestamp info  final  Master
    Get RESET timestamp info  final  Slave
    Get and check BTS RESET info from IMS file  expected_reset_number=1  alias=Master  remove_ims_file=False
    ...  start_point_timestamp_UTC=${date_timestamp_initial_Master_UTC}  end_point_timestamp_UTC=${date_timestamp_final_Slave_UTC}
    Get and check BTS RESET info from IMS file  expected_reset_number=1  alias=Slave  remove_ims_file=False
    ...  start_point_timestamp_UTC=${date_timestamp_initial_Slave_UTC}  end_point_timestamp_UTC=${date_timestamp_final_Slave_UTC}

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]
    ...  Following checks are performed:
    ...  - number of configured cells and radio modules in SCF are properly mapped on BTS running view ADMIN
    ...  - check cells states
    ...  - check radio modules states

    Log  Step ${index}: Check final number and state of Cells and RMs  console=True
    RFS Test Case Final Checks

Get RESET timestamp info
    [Arguments]  ${when}  ${alias}
    Get Current Date UTC info  ${when}_${alias}

Reset Site and export results for iteration
    [Arguments]  ${CYCLE}  ${tech}  ${alias}
    ${tech_upper}=  Convert To Uppercase  ${tech}
    ${tech_lower}=  Convert To Lowercase  ${tech}
    Log  Perform "Reset Site" operation on ${tech_upper} ${alias}  console=True
    Get Current Time  ${tech_lower}_initial
    Log  ${tech_upper} reset_start_time is: ${time_${tech_lower}_initial}  console=True
    RFS Site Reset  wait_for_reconnection=True  connection=${alias}  graceful_cell_shutdown=${GRACEFUL_CELL_SHUTDOWN}
    Get Current Time  ${tech_lower}_before_check
    ${time_substract_var1}=  DateTime.Subtract Date from Date  ${time_${tech_lower}_before_check}  ${time_${tech_lower}_initial}  number
    Set Test Variable  ${${tech_lower}_before_check_elapsed_time}  ${time_substract_var1}
    ${time_substract_var2}=  BuiltIn.Evaluate  ${${tech_upper}_MAX_WAIT_TIME}-${${tech_lower}_before_check_elapsed_time}
    Set Test Variable  ${${tech_lower}_remained_time}  ${time_substract_var2}
    Admin Check BTS Procedural and Blocking states  ${OnAir_}  ${Unblocked_}  ${${tech_lower}_remained_time}  ${alias}
    Get Current Time  ${tech_lower}_final
    ${time_substract_var3}=  DateTime.Subtract Date From Date  ${time_${tech_lower}_final}  ${time_${tech_lower}_initial}  number
    Set Test Variable  ${${tech_lower}_reset_elapsed_time}  ${time_substract_var3}
    Export ResetTime Results  ${alias}  ${BTS Files}/${alias}/ResetTimeInfo.txt  reset_sm  ${tech_lower}  ${CYCLE}
    ...  ${${tech_lower}_reset_elapsed_time}  ${EMPTY}
    ${remain_time}=  BuiltIn.Evaluate  ${${tech_upper}_MAX_WAIT_TIME}-${${tech_lower}_reset_elapsed_time}
    ${remain_time}=  Set Variable If  ${remain_time} <= 0  5  ${remain_time}
    Run Keyword if  '${alias}' == 'Master'
    ...  Assert Every  NRCEL  operationalState=${Enabled_}
    ...  timeout=${remain_time}  alias=${alias}
    Get Current Time  last_check
    ${time_until_last_check}=  DateTime.Subtract Date From Date  ${time_last_check}  ${time_${tech_lower}_initial}  number
    Run Keyword If  '${alias}' == 'Master'  Run Keyword
    ...  Check KPI  ${time_until_last_check}  ${${tech_upper}_RESET_WRN_THR}
    Run Keyword If  '${alias}' == 'Master'  Run Keywords
    ...  Add KPI Results in File  alias=${alias}  kpi_reported=KPI_1a  kpi_log_file=${BTS Files}/${alias}/ResetTimeInfo.txt
    ...  info=first_cell_down_to_last_cell_up  cycle=${CYCLE}  event_value=${time_until_last_check}
    ...  AND  Return From Keyword
    ${time_substract_var4}=  BuiltIn.Evaluate  ${${tech_lower}_reset_elapsed_time}-${${tech_upper}_RESET_WRN_THR}
    Set Test Variable  ${${tech_lower}_time_diff}  ${time_substract_var4}
    Check test verdict based on reset time  ${tech_upper}  ${${tech_lower}_time_diff}

Particular Teardown
    Export ResetTime Results Global

TC Setup
    ${tech_preset_list}=  Create List  SBTS  SBTS
    Common Test Setup  preset_techs=${tech_preset_list}  common_sbts=${TRUE}  infomodelSetup=${FALSE}

TC Teardown
    Common Test Teardown
